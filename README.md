# msg_store_bitcask_index #

This project implements a RabbitMQ _message store index_ using **Bitcask** as backend database. Basically the message index keeps tracks of which messages are stored on which files on your filesystem. For more details on how RabbitMQ's message store work read the documentation on this file which is quite extensive [http://hg.rabbitmq.com/rabbitmq-server/file/59fa7d144fe1/src/rabbit_msg_store.erl](http://hg.rabbitmq.com/rabbitmq-server/file/59fa7d144fe1/src/rabbit_msg_store.erl). There's also a blog post from the RabbitMQ team here: [http://www.rabbitmq.com/blog/2011/01/20/rabbitmq-backing-stores-databases-and-disks/](http://www.rabbitmq.com/blog/2011/01/20/rabbitmq-backing-stores-databases-and-disks/).

# Installation #

Get the `rabbitmq-public-umbrella`

		$ hg clone http://hg.rabbitmq.com/rabbitmq-public-umbrella
		$ cd rabbitmq-public-umbrella
		$ make co

Get the [bitcask_wrapper](https://github.com/videlalvaro/bitcask_wrapper):

Inside the `rabbitmq-public-umbrella` directory do:

		$ git clone git://github.com/videlalvaro/bitcask_wrapper.git

	Then clone this repository:

		$ git clone git://github.com/videlalvaro/msg_store_bitcask_index.git
		$ cd msg_store_bitcask_index
		$ make

Copy the files inside `msg_store_bitcask_index/dist` into your RabbitMQ `plugins` folder. Don't copy the file `rabbit_common-0.0.0.ez`.

Start RabbitMQ and enjoy (and report bugs too).

# NOTE #

This has been nearly not tested at all. I release it here mostly to let people experiment with `Bitcask` to see what are the advantages compared to using plain `ETS` tables with RabbitMQ. For more details about `Bitcask` and it's motivation please see this paper from its authors: [http://downloads.basho.com/papers/bitcask-intro.pdf](http://downloads.basho.com/papers/bitcask-intro.pdf).