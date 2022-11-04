def list_changes(new_override=''):
    dir_path = '/nix/var/nix/profiles/'

    list_of_dirs = sorted(filter(os.path.isdir, glob.glob(dir_path + 'system-*-link')))
    names = [os.path.basename(x) for x in list_of_dirs]
    names.sort(key=lambda x: [int(c) if c.isdigit() else c for c in re.split(r'(\d+)', x)])


    new = ''
    prev = ''

    if len(names) >= 2:
        new = dir_path + names[-1]
        prev = dir_path + names[-2]
        
    elif new_override:
        new = new_override
        prev = dir_path + names[-1]

    if new and prev:
        print(new)
        print(prev)
        subprocess.run([nvd, "diff", prev, new])


def update(options):
    if options.i:
        subprocess.run(["nix", "flake", "lock", "--update-input", options.i])
    else:
        subprocess.run(["nix", "flake", "update"])


def switch(options):
    cmd = ["sudo", "nixos-rebuild", "switch", "--flake", "."]
        
    if options.d:
        cmd += ["--show-trace"]
    
    result = subprocess.run(cmd)

    if result.returncode == 0:
        list_changes()
        
def build(options):
    cmd = []
    
    if options.type:
        cmd += ["sudo", "nixos-rebuild", options.type, "--flake", "."]
    else:
        cmd += ["sudo", "nixos-rebuild", "build", "--flake", "."]
        
    if options.d:
        cmd += ["--show-trace"]

    result = subprocess.run(cmd)
    
    if result.returncode == 0:
        if options.type:
            list_changes('.result')
        else:
            list_changes()
    

def clean(options):
    subprocess.run(["sudo", "nix-collect-garbage", "-d"])
    subprocess.run(["sudo", "nix-store", "--optimise"])
    
    
def rollback(options):
    subprocess.run(["sudo", "nixos-rebuild", "switch", "--flake", ".", "--rollback"])
    

def show(options):
    match options.arg:
        case 'generations':
            subprocess.run(["sudo", "nix-env", "--list-generations", "--profile", "/nix/var/nix/profiles/system"])
        case 'installed':
            subprocess.run([nvd, "list"])
        case 'changes':
            list_changes()
        case 'tree':
            subprocess.run(["nix-tree"])
   

def backup(options):
    today = date.today()
    id = today.strftime("%d-%m-%Y")
    
    result = subprocess.run(["mountpoint", "-q", "/media/backup"])

    if result.returncode != 0:
        subprocess.run(["sudo", "mkdir", "-p", "/media/backup"])
        result = subprocess.run(["sudo", "mount", "/dev/disk/by-label/backup", "/media/backup"])
    

    if result.returncode == 0:
        match options.arg:
            case 'media':
                subprocess.run(["sudo", borg, "create", 
                        "-e", "/nix/persist/home/*/config",
                        "-e", "/nix/persist/home/*/projects",
                        "/media/backup::media-" + id,
                        "/nix/persist/home"])
            case 'projects':
                subprocess.run(["sudo", borg, "create", 
                        "-e", "/nix/persist/home/*/Media",
                        "-e", "/nix/persist/home/*/Downloads",
                        "/media/backup::projects-" + id,
                        "/nix/persist/home"])
    else:
        print(result.stderr)
        

def doc(options):
    subprocess.run([doc_cmd, "search", options.string, doc_source])
    

def src(options):
    path = subprocess.run(["nix", "eval", "--raw", ".#self.inputs.nixpkgs.outPath"], capture_output=True, text=True)
    subprocess.run([options.cmd], cwd=path.stdout, shell=True)


def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    parser_update = subparsers.add_parser('update', help='update the flake')
    parser_update.add_argument('-i', '-input', type=str, help='optional input to update')
    parser_update.set_defaults(func=update)

    parser_switch = subparsers.add_parser('switch', help='nixos-rebuild switch/build/boot')
    parser_switch.add_argument('-d', '-debug', action='store_true', help='enable debug log')
    parser_switch.set_defaults(func=switch)

    parser_build = subparsers.add_parser('build', help='nixos-rebuild build')
    parser_build.add_argument('type', type=str, help='build/boot/dry-run', nargs='?', default='build')
    parser_build.add_argument('-d', '-debug', action='store_true', help='enable debug log')
    parser_build.set_defaults(func=build)

    parser_clean = subparsers.add_parser('clean', help='clean the nix store')
    parser_clean.set_defaults(func=clean)

    parser_rollback = subparsers.add_parser('rollback', help='nixos rollback')
    parser_rollback.set_defaults(func=rollback)

    parser_show = subparsers.add_parser('show', help='list various helpful things')
    parser_show.add_argument('arg', type=str, help='either generations/installed/changes/tree')
    parser_show.set_defaults(func=show)

    parser_backup = subparsers.add_parser('backup', help='backup')
    parser_backup.add_argument('arg', type=str, help='either media/projects', 
                            nargs='?', default='projects', choices=["projects", "media"])
    parser_backup.set_defaults(func=backup)
    
    parser_doc = subparsers.add_parser('doc', help='search fo functions in nixpkgs')
    parser_doc.add_argument('string', type=str)
    parser_doc.set_defaults(func=doc)

    parser_src = subparsers.add_parser('src', help='cd to src')
    parser_src.add_argument('cmd', type=str)
    parser_src.set_defaults(func=src)
    
    

    if len(sys.argv) <= 1:
        sys.argv.append('--help')

    options = parser.parse_args()

    options.func(options)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        try:
            sys.exit(0)
        except SystemExit:
            os._exit(0)
