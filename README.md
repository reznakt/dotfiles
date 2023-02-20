# dotfiles

My personal collection of dotfiles, other configuration files, scripts and other. 

## Usage
- `./dotfiles pull` - update local configurations
- `./dotfiles push` - stage local configuration for updating the remote

Rules for copying files are defined in the `dotfiles.map` file as 2-tuples - (*source*, *destination*).

The log of all copied files and their respective backups is saved to `dotfiles.log`.
