# ft_transcendence

This is our final project at 42: Transcendence. It uses the [Phoenix Framework](https://www.phoenixframework.org/) & Elixir in the backend, PostgreSQL as a database, and [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) in the frontend.

# Getting started

1. Clone the repo
2. Add a `.env`:
```sh
cp .env.example .env
```
3. Add the three missing parts: The `POSTGRES_USER` and `POSTGRES_PASSWORD`, as well as the secret (later).
4. (In case you didn't do that yet, install and/or start Docker/your docker daemon.)
5. Start up the containers:
```sh
docker compose up --build
```
6. Generate your secret:
```sh
./run secret
```
7. Insert your secret into the `.env` file: `SECRET_KEY_BASE`
8. And now, finally, it is time to start `ft_transcendence`:
```sh
docker compose up --build
```
9. Open up your favorite browser at <http://localhost:8000> and enjoy :)


-------

A big thanks to Nick Janetakis for providing this [very nice setup](https://github.com/nickjj/docker-phoenix-example)!