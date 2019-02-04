#! /bin/bash

set -e

TOKEN=$1

if [ "$TOKEN" == ""  ]; then echo "Require token."; exit -1; fi

CLUSTER_NAME=library.yun.technology
NICKNAME=library
USERNAME=your_namespace
MASTER_LOAD_BALANCER=library.yun.technology

MASTERCRT="-----BEGIN CERTIFICATE-----
MIIC0zCCAbugAwIBAgIMFX/AV03O18ggKIFuMA0GCSqGSIb3DQEBCwUAMBUxEzAR
BgNVBAMTCmt1YmVybmV0ZXMwHhcNMTkwMjAxMDQzMTE4WhcNMjkwMTMxMDQzMTE4
WjAVMRMwEQYDVQQDEwprdWJlcm5ldGVzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
MIIBCgKCAQEAk0xpUd+7hTsLOr3QjH9jR3CjULlo6ygU4l+nKytP0tivJkva0pOI
KO/tOgZzUSsb8PdYTY6rTJ3D124rVtMRAVA+Z0+lbq2KLDMeQ9XjMifrdUxvSUwm
4rTQ7MAivG1xHu5hgq44mn9pgx1Z4VqHIiXmNImEmTLzFa5QBD8ui/c7wx9bo05A
6lVvy8ltk1kyQ+6suBe/SbBmiJJe0cPH7mhk4MnLhUbR5UZ9Tdo5LGCqNmkmPApn
3QcOeLuFn/9r4tS01ChT+38OZTiYw95nXLPSYCaX680sVRf1nWRTFhLbAbz2nmrO
B50PVIVK2Wd70o8dBcuq04I7GF4RSFCFAwIDAQABoyMwITAOBgNVHQ8BAf8EBAMC
AQYwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAVRKyNxm+Qqzm
XXR7f8pNdwasucheIMASzeSugU2smOTSjx/GnUetX4+wHGAJar67u9zIN4RS+wRD
l+OknNeAijrCjKnl0/94FqeRpgHP3dRluzdM6kheVss0GELKjj8V5aG+11hNH7Hj
cGyxDjhyWNdkh2T74FKhikj9mW1vqTAuUFBwXRVDrY5U37ZDw/fCwLxvAAy3ETkz
7ry7UoD5M+3Gl2OGa3/41a3XVK8+wnseSCv1F9zf+LxkLWXJuDANz4nvTJ/Va2+r
Qlw3/ZPjFTv1IayiVODZVgW9Y1WF+EsCjIhuVA7VTbKdvwYUlxyHz7/h60b9oDTa
vqjWXaqj6g==
-----END CERTIFICATE-----"

echo Cluster name: $CLUSTER_NAME
echo Master elb  : $MASTER_LOAD_BALANCER

touch master-ca.crt
echo "$MASTERCRT" >> master-ca.crt
CA_CRT=master-ca.crt

kubectl config set-cluster $CLUSTER_NAME --server=https://api.$MASTER_LOAD_BALANCER --certificate-authority=$CA_CRT --embed-certs=true
kubectl config set-credentials $USERNAME --token=$TOKEN
kubectl config set-context $CLUSTER_NAME --cluster=$CLUSTER_NAME --user=$USERNAME
kubectl config use-context $CLUSTER_NAME

#cd ..
rm -rf master-ca.crt

