

# Build Instructions
## Scryer Prolog WASM

### Downloading prebuilt binaries

- Sometimes there are issues building Scryer for WASM from source [https://github.com/mthom/scryer-prolog/issues/3196](https://github.com/mthom/scryer-prolog/issues/3196)

In Github Actions, you can download a tested binary from a CI run
[https://github.com/mthom/scryer-prolog/actions/runs/28913143019](https://github.com/mthom/scryer-prolog/actions/runs/28913143019)

### Building from source
[Scryer Prolog](https://github.com/mthom/scryer-prolog) can be downloaded and built with 
```
wasm-pack build --target web -- --no-default-features
```
the built files are stored in the `pkg/` directory 

> the nightly commit might not compile. If so, `git checkout` the last commit for a released version

