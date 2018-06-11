# Manifest for Rust firewall

## Installation

First, use repo to set up your local copy:
```
mkdir test
cd test
repo init -u https://github.com/GaloisInc/rustwall_vm
repo sync
```

Initialize Rust environment with:
```
./setup_rust_env.sh
```

**NOTE:** If you are using a rust component with a build script (typically `build.rs` and `build=...` in `Cargo.tomhl`), use the experimental script `./setup_rust_env_with_std_build.sh`

and then you can build an image with firewall for CMA34CR with:

```
make clean; make cma34cr_centos_defconfig; make silentoldconfig; make;
```

If everything goes well, you should have two images:
```
ls images/
capdl-loader-experimental-image-x86_64-pc99  kernel-x86_64-pc99
```

The images are x86_64, and currently require appropriate hardware to run (no QEMU yet, sorry).

## Simple rust application
Initialize the repo as described above.

Then select `simple` app:
```
make clean; make x86_simple_defconfig; make silentoldconfig; make;
```

You end up having two x86-64 targets. To run the simple app from QEMU, type:

```
qemu-system-x86_64 -m 512 -kernel images/kernel-x86_64-pc99 -initrd images/capdl-loader-experimental-image-x86_64-pc99 --enable-kvm -smp 2 -cpu Nehalem,+vmx -nographic
```

and you should see:

```
...
Starting node #0 with APIC ID 0
Mapping kernel window is done
Booting all finished, dropped to user space
Hello from rust
```
## Docker
You can build the images using attached dockerfile. This takes a while, because the build compiles a custom
version of rust compiler from scratch. All you need to do is:
```
sudo docker build -f Dockerfile_compiler .
```
and the docker image is build. 


To build seL4 images, use:

```
sudo docker build -f Dockerfile_images .
```


That dockerfile has already built the Rustwall demo! Annoyingly,
Docker doesn't let you extract files directly from images, but only
from 'containers' (i.e. images that have already been run), so to
extract the compiled artifacts out of the Dockerfile, you need these
slightly hairier commands:

```
  docker cp "$(docker create $IMAGE):/opt/vm/images/kernel-x86_64-pc99" .
  docker cp "$(docker create $IMAGE):/opt/vm/images/capdl-loader-experimental-image-x86_64-pc99" .
```
Where `$IMAGE` is whatever you named the image during the Docker build
step. (The `docker create` command runs an image to create a
container, and then `docker cp` grabs a file from the container and
puts it on the file system.)


## Debugging
Initialize repo with:
```

repo init -u https://github.com/GaloisInc/rustwall_vm -m debug.xml
```

and build the CMA34 app:

```
make clean; make cma34cr_centos_defconfig; make silentoldconfig; make;
```


## Rust and seL4

What was tested and works:
- `std::Box`
- `std::vec`
- `std::Arc`
- `smoltcp` with `alloc`
- `lazy_staic!` crate
- `spin` crate
- `println_sel4` which is a wrapper around `prinf()` and can be used instead of `println!()`
- custom Mutex (note that `std::sync::Mutex` does not work

What does not and will not work:
- threads (besides those provided by Camkes)

