# Changelog

1.1
-----
* Do less monkey patching on the original Jbuilder class. Only add the partial methods defined by the user, otherwise leave Jbuilder alone and leave the rest to a proxy class.
* Make sure all view helper methods are available in partials, not just route helpers.
* Add Rails generator for initializer file.
