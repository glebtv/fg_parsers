Парсеры
==========

При любом подозрении на ошибку или изменение структуры HTML сайта парсер должен происходить exteption. Парсеры разрабатываются не для разового ручного запуска.

```
    raise ParserError, 'Ошибка парсера - изменилось то то и то то'
```

1. Парсер должен наследовать от ParserBase
2. Парсер должен переопределять методы init и parse.
3. Парсер может создавать категории и наборы опций. Категории могут быть вложенными (не более 1 уровня). Как сделать вложенные категории: https://github.com/glebtv/mongoid_nested_set
4. Ссылка на картинку - в максимальном имеющемся разрешении. Обычно, при клике на картинку на сайте можно увидеть версию бОльшего размера, нужна именно эта версия.
5. Файл парсера - с дефисами, название класса Parser + название ресторана
6. Примеры парсеров - в папке parsers (пример simple - понятный и простой, но не рабочий.)

Подготовка к работе
==========
1. Установить MongoDB (http://www.mongodb.org/), или создать бесплатный аккаунт на любом mongodb-хостинге (https://mongohq.com/home, https://mongolab.com/home)
2. Установить Ruby 1.9.3
3. gem install bundler && bundle install

Запуск парсера
==========
```
    ./run.rb corleone-pizza
```

