# fudo-challenge

Para levantar la aplicación:
```
bundle install
bundle exec puma -C .\config\puma.rb
```

Para correr tests:
```
bundle exec ruby tests/app_test.rb
```

### Comandos útiles (Windows):

#### Crear un usuario:
```
curl.exe -s -X POST http://localhost:3000/users -d "username=test-user&password=secret"
```
#### Autenticar con el usuario creado
```
$login = curl.exe -s -X POST http://localhost:3000/login -d "username=test-user&password=secret"
$token = ($login | ConvertFrom-Json).session_token
```
#### Crear un producto
```
curl.exe -s -X POST http://localhost:3000/products -d "name=New Product" -H "Authorization: Bearer $token"
```
#### Listar productos
```
curl.exe -s http://localhost:3000/products -H "Authorization: Bearer $token"
```