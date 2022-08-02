### bookinfo external web service
#### deatils-v2 googleapi 연결 안됨
![](../img/스크린샷 2022-06-21 오후 2.07.17.png)
* service entry(googleapi-service-entry.yaml)
* virtual service(googleapi-service-entry.yaml)
* egress gateway(bookinfo-egressgateway.yaml)
```shell
ganghyeyeon@hykang bookinfo % kubectl exec "$SOURCE_POD" -c sleep -- curl -sSI https://www.googleapis.com | grep "HTTP/"
curl: (35) error:1408F10B:SSL routines:ssl3_get_record:wrong version number
command terminated with exit code 35
```
* service-entry-google-https.yaml
````shell
ganghyeyeon@hykang bookinfo % kubectl exec "$SOURCE_POD" -c sleep -- curl -sSI https://www.google.com | grep "HTTP/" 
HTTP/2 200
````
isbn 문제..? 
www.googleapis.com/books/v1/volumes?q=isbn:0486424618
