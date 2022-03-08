#!/bin/bash
echo "Create root key..."
openssl genrsa -out ca.key 2048
openssl req -new -x509 -key ca.key -out ca.crt -days 3650
echo "Create server key..."
openssl genrsa -out server.key 2048
echo "Create server certificate signing request..."
openssl req -new -key server.key -out server.csr -days 365
echo "Sign SSL certificate..."
openssl x509 -req -days 365 -sha256 -CA ca.crt -CAkey ca.key -CAcreateserial -extfile openssl.cnf -extensions v3_req -in server.csr -out server.crt
