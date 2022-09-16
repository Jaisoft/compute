mvn archetype:generate -DgroupId=com.mycompany.app -DartifactId=my-app -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false


cd my-app

mvn clean

mvn package

java -cp target/my-app-1.0-SNAPSHOT.jar com.mycompany.app.App


docker image build . -t my-app


docker container run my-app


