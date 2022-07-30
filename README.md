# Bref.sh Terraform

Terraform example for [bref.sh](https://bref.sh) laravel deploy.

[bref.sh](https://bref.sh) has native support for serverless framework type of deploy. This repository replicates the _serverless deploy_ but in terraform manifests.

## Prepare Laravel projet for deploy

This commands should be run on the Laravel project folder

Clear cache files from local machine

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

First copy the archive **latest.zip** generated earlier in the root of this repository. Then apply the terraform manifests.

```
$ terraform apply
```

Finally, terraform should create the same resources that serverless framework would have created.
