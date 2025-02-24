{ inputs, config, pkgs, lib, ... }:

{
    # Enable the OpenSSH daemon.
    services.openssh = {
        enable = true;
        ports = [ 22 ];
        settings = {
            PasswordAuthentication = false;
            AllowUsers = null;
            UseDns = false;
            X11Forwarding = false;
            PermitRootLogin = "no";
        };
    };

    users.users.${config.sidonia.userName}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfNV3Z/LI/4ItskdADIC4JWqfW3Wae4TRK/Ahos5TgB hazama@kaoru"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+PU2qFuxv85HjylmQTqmsgR1h9un6bhFeoFlQJ0MgJHNZWPYOavpQqEUQ/SvMH+X7FkiPPyn3u26POhTyUZtgJtVgABi7rs1v1B19ADZ9/9NVW6jNqho7YQpmruNEXqJnIJPMRItq6a6mH9L22X76ti2KjMdh2lluzf9BIBCfiU177VkRx1M4mXdKy2Gd2eLsqoJDnKh/6LqAyO/qzGx6pufAg+id44J9iNrRmJZKm+bZCJUaaRrX5qmNyL/DO7wD+ulFBimt/DEn86R3H1/K04/8ZV4jEmFVKsYh2fGes0ZiHM3oqNCt2okDQpQqqcsZ1bKiA2qSSgCwWJgaIHE9 quinn@QUINN-RYZEN"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICw5RRyu1jEMpS5ekIfbdaHtWU/IyZ62LhfqK8xUIjGY shinatose@yure"
    ];

}
