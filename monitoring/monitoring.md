### Prometheus
### Grafana
#### Prometheus datasource timeout
![](../img/스크린샷 2022-06-20 오전 10.59.40.png)
보안그룹 문제??
</br>
node의 메트릭을 prometheus에서 수집 -> grafana가 prometheus가 수집한 메트릭을 읽음
</br>
포트 지정안해줘서
#### details-v2 를 배포하니 서버가 죽음 => 왜?
details-v2가 400에러를 준다 -> 근데 왜 일시적으로 productpage 접속이 안되는지?
=> 문제가 있는 버전을 배포해도 사이트가 안죽도록 하는 방법??