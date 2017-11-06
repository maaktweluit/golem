from docker import Client
from docker.utils import kwargs_from_env

kwargs = kwargs_from_env(assert_hostname=False)

client = Client(**kwargs)

cont2 = client.create_container(image="golemfactory/base:1.2",
                                network_disabled=True)

client.start(cont2.get("Id"))
