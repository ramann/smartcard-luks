#!/bin/bash

pkcs15-init -E
pkcs15-init -vvvvvvvvv --create-pkcs15 -p pkcs15+onepin
pkcs15-init -vvvvvvvvv -G rsa/1024 -i 45 -a 01 -u sign,decrypt --pin 1234
pkcs15-tool --read-public-key 45 -o public_key_rsa1024.pem
echo "This is just some plain text." > plain.txt
openssl dgst -md5 -binary -out plain.txt.md5 < plain.txt
pkcs15-crypt -vvvvvvvvv -s --md5 --pkcs1 -i plain.txt.md5 -o plain.txt.sign
openssl dgst -verify puk.rsa.1024.pem -md5 -signature plain.txt.sign < plain.txt
openssl rsautl -pubin -inkey puk.rsa.1024.pem -encrypt -in plain.txt -out plain.txt.enc
pkcs15-crypt -vvvvvvvvv -c --pkcs1 -i plain.txt.enc -o plain.txt.dec


