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

Run part 1 of the bash script:  
```
./make-key.sh <Name> 1
```

Enter a temporary password when prompted to.  
![alt text](https://github.com/chronolator/CreateMOK/blob/master/images/temp-password.png)

You will be prompted to reboot, so that you can enter MOK utility management.  
![alt text](https://github.com/chronolator/CreateMOK/blob/master/images/reboot.png)

You might have to press a key for the MOK utility management tool to display.  
Select `Enroll MOK`.  
![alt text](https://github.com/chronolator/CreateMOK/blob/master/images/EnterMOK-management.png)

Select `Continue`.  
![alt text](https://github.com/chronolator/CreateMOK/blob/master/images/MOK-continue.png)

Select `Yes`  
![alt text](https://github.com/chronolator/CreateMOK/blob/master/images/MOK-yes.png)

Enter the temporary password from before.  
![alt text](https://github.com/chronolator/CreateMOK/blob/master/images/MOK-temp-password.png)

Run part 2 of the bash script:  
```
./make-key.sh <Name> 2
```  
![alt text](https://github.com/chronolator/CreateMOK/blob/master/images/createMOK-part2.png)

You can now start signing LKMs.
