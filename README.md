# CreateMOK
Bash script which will attempt to create a Machine Owner Key (MOK) on a UEFI system.  This will allow a user to sign Loadable Kernel Modules (LKMs) when secure boot is enabled.

## Dependencies
Ensure your system is utilizing UEFI.  You can check by seeing if `/sys/firmware/efi` exists.

## Install
Clone the repository:

```
git clone https://github.com/chronolator/CreateMOK.git
```

Enter the folder: 

```
cd CreateMOK
```

Run bash script:

```
./make-key.sh epicname 1
```

Enter a temporary password when prompted to.
![alt text](https://github.com/inessadl/readme/blob/master/img/ff_logo2013.png)
