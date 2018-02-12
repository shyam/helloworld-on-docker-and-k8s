## Packaging of `helloworld.war` app

### Notes:

`helloworld` is a Java Sprint Boot microservice. The `helloworld` container packages the `helloworld.war` and its entry point script `entrypoint.sh`. It depends on a custom `alpine-java` image which internally depends on `alpine` image.

Although `alpine-java` is forked from an 3rd party, the rationale of having `alpine-java` as separate container within our registry is to have an official internal image. It enables us to selectively control the JVM updates and ensure security.

The `Dockerfile` sources and other artifacts for both the containers can be found within the respective directories.

### Steps to build, tag and push:

The steps assume a push to my public [Docker Hub repository (shyam)](https://hub.docker.com/r/shyam/). 

* alpine-java

````
[alpine-java]$ docker build -t alpine-java:8u162b12 .
Sending build context to Docker daemon  6.144kB
[...]
Successfully built a0e35b85e42d
Successfully tagged alpine-java:8u162b12
[alpine-java]$ docker tag a0e35b85e42d shyam/alpine-java:8u162b12 
[alpine-java]$ docker push shyam/alpine-java:8u162b12
The push refers to repository [docker.io/shyam/alpine-java]
[...]
8u162b12: digest: sha256:58725290618ed8a093c64f429eb8de7fa1e84a5d316cf86502bdeb9570a4d438 size: 741
````

* helloworld

````
[helloworld]$ docker build -t helloworld:v1 .
Sending build context to Docker daemon  18.47MB
[...]
[...]
Successfully built 72ff30f65169
Successfully tagged helloworld:v1
[helloworld]$ docker tag 72ff30f65169 shyam/helloworld:v1
[helloworld]$ docker push shyam/helloworld:v1
The push refers to repository [docker.io/shyam/helloworld]
[...]
v1: digest: sha256:c8b9256fbfc9ff792ea112df3a21a561a187208059993d658c8cb4a9489cb74b size: 1365
````

### (Optional) Steps to test helloworld run on local:

````
$ docker run -p 8080:8080 -t helloworld:v1
current image environment vars.
JAVA_VERSION_BUILD=12
HOSTNAME=ceda31edf0e2
TERM=xterm
JAVA_VERSION_MAJOR=8
GLIBC_VERSION=2.26-r0
JAVA_OPTS=-Xmx256m
JAVA_JCE=unlimited
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jdk/bin
GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc
PWD=/app
JAVA_HOME=/opt/jdk
LANG=C.UTF-8
SHLVL=1
HOME=/root
INSTALL_PATH=/app
JAVA_PACKAGE=jdk
JAVA_VERSION_MINOR=162
_=/usr/bin/env
-----

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v1.4.2.RELEASE)

2018-02-11 11:38:36.934  INFO 1 --- [           main] com.mkyong.SpringBootWebApplication      : Starting SpringBootWebApplication v1.0 on ceda31edf0e2 with PID 1 (/app/helloworld.war started by root in /app)
2018-02-11 11:38:36.939  INFO 1 --- [           main] com.mkyong.SpringBootWebApplication      : No active profile set, falling back to default profiles: default
2018-02-11 11:38:37.114  INFO 1 --- [           main] ationConfigEmbeddedWebApplicationContext : Refreshing org.springframework.boot.context.embedded.AnnotationConfigEmbeddedWebApplicationContext@5b37e0d2: startup date [Sun Feb 11 11:38:37 GMT 2018]; root of context hierarchy
2018-02-11 11:38:39.099  INFO 1 --- [           main] s.b.c.e.t.TomcatEmbeddedServletContainer : Tomcat initialized with port(s): 8080 (http)
2018-02-11 11:38:39.133  INFO 1 --- [           main] o.apache.catalina.core.StandardService   : Starting service Tomcat
2018-02-11 11:38:39.142  INFO 1 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet Engine: Apache Tomcat/8.5.6
2018-02-11 11:38:40.391  INFO 1 --- [ost-startStop-1] org.apache.jasper.servlet.TldScanner     : At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.
2018-02-11 11:38:40.783  INFO 1 --- [ost-startStop-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2018-02-11 11:38:40.783  INFO 1 --- [ost-startStop-1] o.s.web.context.ContextLoader            : Root WebApplicationContext: initialization completed in 3673 ms
2018-02-11 11:38:41.002  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.ServletRegistrationBean  : Mapping servlet: 'dispatcherServlet' to [/]
2018-02-11 11:38:41.007  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'characterEncodingFilter' to: [/*]
2018-02-11 11:38:41.008  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'hiddenHttpMethodFilter' to: [/*]
2018-02-11 11:38:41.009  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'httpPutFormContentFilter' to: [/*]
2018-02-11 11:38:41.010  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'requestContextFilter' to: [/*]
2018-02-11 11:38:41.406  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerAdapter : Looking for @ControllerAdvice: org.springframework.boot.context.embedded.AnnotationConfigEmbeddedWebApplicationContext@5b37e0d2: startup date [Sun Feb 11 11:38:37 GMT 2018]; root of context hierarchy
2018-02-11 11:38:41.510  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/]}" onto public java.lang.String com.mkyong.WelcomeController.welcome(java.util.Map<java.lang.String, java.lang.Object>)
2018-02-11 11:38:41.515  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/error],produces=[text/html]}" onto public org.springframework.web.servlet.ModelAndView org.springframework.boot.autoconfigure.web.BasicErrorController.errorHtml(javax.servlet.http.HttpServletRequest,javax.servlet.http.HttpServletResponse)
2018-02-11 11:38:41.516  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/error]}" onto public org.springframework.http.ResponseEntity<java.util.Map<java.lang.String, java.lang.Object>> org.springframework.boot.autoconfigure.web.BasicErrorController.error(javax.servlet.http.HttpServletRequest)
2018-02-11 11:38:41.562  INFO 1 --- [           main] o.s.w.s.handler.SimpleUrlHandlerMapping  : Mapped URL path [/webjars/**] onto handler of type [class org.springframework.web.servlet.resource.ResourceHttpRequestHandler]
2018-02-11 11:38:41.564  INFO 1 --- [           main] o.s.w.s.handler.SimpleUrlHandlerMapping  : Mapped URL path [/**] onto handler of type [class org.springframework.web.servlet.resource.ResourceHttpRequestHandler]
2018-02-11 11:38:41.623  INFO 1 --- [           main] o.s.w.s.handler.SimpleUrlHandlerMapping  : Mapped URL path [/**/favicon.ico] onto handler of type [class org.springframework.web.servlet.resource.ResourceHttpRequestHandler]
2018-02-11 11:38:42.288  INFO 1 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Registering beans for JMX exposure on startup
2018-02-11 11:38:42.424  INFO 1 --- [           main] s.b.c.e.t.TomcatEmbeddedServletContainer : Tomcat started on port(s): 8080 (http)
2018-02-11 11:38:42.434  INFO 1 --- [           main] com.mkyong.SpringBootWebApplication      : Started SpringBootWebApplication in 6.349 seconds (JVM running for 7.095)
[....]
````

