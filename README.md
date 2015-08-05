# opensc_luks
## How to use a PKCS#15-compliant smartcard to unlock a LUKS encrypted root
This has been tested on Ubuntu 14.04 LTS with a Feitian PKI (FTCOS/PK-01C) smartcard and a generic USB smartcard reader.

### The general steps:
* Erase and initialize card
* Create public/private key pair on smartcard
* Create key file and add it to a LUKS key slot
* Encrypt key file using public key from smartcard
* Modify initramfs to use smartcard to decrypt the encrypted keyfile

### The details:
1. Install smartcard middleware

    ```sudo apt-get install pcscd opensc```

2. Erase smartcard

    ```pkcs15-init -E```
    
3. Initialize smartcard

    ```pkcs15-init --create-pkcs15 -p pkcs15+onepin --pin 1234 --puk 4321```
    
4. Create public/private key pair on smartcard

    ```pkcs15-init -G rsa/2048 -i 01 -a 01 -u decrypt --pin 1234```
    
5. Create a random key file and add it to a LUKS key slot

    ```dd if=/dev/random of=~/key bs=1 count=256```
    
    ```sudo cryptsetup luksAddKey /dev/sda2 ~/key```
    
6. Export the public key from smartcard

    ```pkcs15-tool --read-public-key 01 -o public_key_rsa2048.pem```

7. Encrypt key file using public key

    ```openssl rsautl -encrypt -pubin -inkey public_key_rsa2048.pem  -in ~/key -out ~/key.enc```
