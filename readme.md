# Automatically finds, loads and reloads classes

Suppose there's following directory structure:

    /lib
      /some_class.rb        # class SomeClass; end
      /some_namespace
        /another_class.rb   # class SomeNamespace:AnotherClass; end
      /some_namespace.rb    # module SomeNamespace; end

All these classes will be loaded automatically:

``` ruby
require 'class_loader'

SomeClass
SomeNamespace::AnotherClass
```

No need for `require`, `autoload` and code like this:

``` ruby
require 'some_class'
require 'some_namespace'
require 'some_namespace/another_class'

autoload :SomeClass,      'some_class'
autoload :SomeNamespace,  'some_namespace'
module SomeNamespace
  autoload :AnotherClass, 'some_namespace/another_class'
end
```

Watching and reloading changed classes:

``` ruby
ClassLoader.watch 'my_app/lib'
```

Preload classes eagerly:

``` ruby
ClassLoader.preload 'my_app/lib'
```

Execute callbacks after loading class:

``` ruby
ClassLoader.after 'SomeClass' do |klass|
  klass.include SomeModule
end
```

It's also very small, sources are about 150 lines (and third of it are comments).

## Installation

	$ gem install class_loader

## License

Copyright (c) Alexey Petrushin http://petrush.in, released under the MIT license.