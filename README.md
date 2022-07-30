# brefsh-terraform

Terraform example for bref.sh laravel deploy.

## Prepare Laravel projet for deploy

This command should be run on laravel project folder

Clear cache files from local

```
$ php artisan config:clear
```

For production, let's remove development dependencies and optimize Composer's autoloader

```
$ composer install --prefer-dist --optimize-autoloader --no-dev
```

Prepare the zip archive

```
$ zip -r latest.zip . -x "*node_modules*" "*public/storage*" "*resources/assets*" "*storage/**\*" "./*tests*" "*.git*" "*.env*"
```

## Appy terraform

First copy the archive **latest.zip** generated earlier in the root of this repository.

```
$ terraform apply
```
