# firvish.nvim

**Note that this fork is currently very unstable due to ongoing refactors.**

Firvish is primarily a job control library for neovim. Additionally it
provides mechanisms which promote _buffer-centric_ semantics as a means of
working with job output.

See the [docs](docs/firvish.txt) for help.
See [examples](contrib/examples/) for examples.

## Extensions

Several plugins exist which use firvish internally.

- [buffers.firvish][buffers]: use `:Buffers` to open the "buffer list"
- [git.firvish][git]: vim-fugitive, but using firvish
- [jobs.firvish][jobs]: use `:Jobs` to open the "job list"

[buffers]: https://github.com/willruggiano/buffers.firvish
[git]: https://github.com/willruggiano/git.firvish
[jobs]: https://github.com/willruggiano/jobs.firvish
