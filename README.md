dynasign-b3
===========
Interactive e-mail/password sign-up/auth w/ Mailgun validation API, Iron-Router, Parsley, and helpless-b3...

see http://mib3.meteor.com

###dynaSign

An inline navbar widget for dynamically interacting with user.

add keys.coffee file with a  mailgun.com public-api-key for e-mail validation.

```coffeescript
@b3.validate_api_key = '<mailgun.com public-api-key>'
```
Insert into your navbar.

```handlebars

<ul class="nav navbar-nav navbar-right">
  {{> dynaSign}}
</ul>

```


