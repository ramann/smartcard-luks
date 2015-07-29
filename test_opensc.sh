#!/bin/bash
#verbose='-vvvvvvvvv'

echo "erase card"
pkcs15-init -E

echo "create pkcs15 structure"
pkcs15-init $verbose --create-pkcs15 -p pkcs15+onepin --pin 1234 --puk 4321

echo "create public/private keys"
pkcs15-init $verbose -G rsa/2048 -i 01 -a 01 -u sign,decrypt --pin 1234

echo "export public key"
pkcs15-tool --read-public-key 01 -o public_key_rsa2048.pem

echo "create a simple file"
echo "This is just some plain text." > plain.txt

echo "hash the file"
openssl dgst -sha256 -binary -out plain.txt.sha256 < plain.txt

echo "sign the hash"
pkcs15-crypt $verbose -s --pin 1234 --sha-256 --pkcs1 -i plain.txt.sha256 -o plain.txt.sign

echo "verify the signature"
openssl dgst -verify public_key_rsa2048.pem -sha256 -signature plain.txt.sign < plain.txt

echo "encrypt the file"
openssl rsautl -pubin -inkey public_key_rsa2048.pem -encrypt -in plain.txt -out plain.txt.enc

echo "decrypt the file"
pkcs15-crypt $verbose -c --pin 1234 --pkcs1 -i plain.txt.enc -o plain.txt.dec

