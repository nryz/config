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
        new = dir_path + new_override
        prev = dir_path + names[-1]

    if new and prev:
        print(new)
        print(prev)
        subprocess.run([nvd, "diff", prev, new])


def update(options):
    if options.i:
        if options.i == 'packages':
            subprocess.run(["nix", "flake", "update", "./packages"])

        subprocess.run(["nix", "flake", "lock", "--update-input", options.i])
    else:
        subprocess.run(["nix", "flake", "update", "./packages"])
        subprocess.run(["nix", "flake", "update"])


def switch(options):
    cmd = []
    if options.t:
        cmd += ["sudo", "nixos-rebuild", options.t, "--flake", "."]
    else:
        cmd += ["sudo", "nixos-rebuild", "switch", "--flake", "."]
        
    if options.d:
        cmd += ["--show-trace"]
    
    subprocess.run(cmd)

    if options.t == 'build':
        list_changes('./result')
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
   

def install(options):
    print('TODO')
    
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
                        "-e", "/nix/persist/home/*/videos",
                        "-e", "/nix/persist/home/*/music",
                        "-e", "/nix/persist/home/*/downloads",
                        "-e", "/nix/persist/home/*/pictures",
                        "-e", "/nix/persist/home/*/documents",
                        "/media/backup::projects-" + id,
                        "/nix/persist/home"])
    else:
        print(result.stderr)
    


def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    parser_update = subparsers.add_parser('update', help='update the flake')
    parser_update.add_argument('-i', '-input', type=str, help='optional input to update')
    parser_update.set_defaults(func=update)

    parser_switch = subparsers.add_parser('switch', help='nixos-rebuild switch/build/boot')
    parser_switch.add_argument('-t', '-type', type=str, help='switch/build/boot defaults to switch')
    parser_switch.add_argument('-d', '-debug', action='store_false', help='enable debug log')
    parser_switch.set_defaults(func=switch)

    parser_clean = subparsers.add_parser('clean', help='clean the nix store')
    parser_clean.set_defaults(func=clean)

    parser_rollback = subparsers.add_parser('rollback', help='nixos rollback')
    parser_rollback.set_defaults(func=rollback)

    parser_show = subparsers.add_parser('show', help='list various helpful things')
    parser_show.add_argument('arg', type=str, help='either generations/installed/changes/tree')
    parser_show.set_defaults(func=show)

    parser_install = subparsers.add_parser('install', help='TODO: install the nixos system')
    parser_install.set_defaults(func=install)

    parser_install = subparsers.add_parser('backup', help='backup')
    parser_install.add_argument('arg', type=str, help='either media/projects', 
                            nargs='?', default='projects', choices=["projects", "media"])
    parser_install.set_defaults(func=backup)

    if len(sys.argv) <= 1:
        sys.argv.append('--help')

    options = parser.parse_args()

    os.chdir(config_path)
    options.func(options)
    


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        try:
            sys.exit(0)
        except SystemExit:
            os._exit(0)
