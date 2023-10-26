# Fixing Broken Access Control
## OWASP 2023 Global AppSec DC

[Session URL](https://sched.co/1ObH0)
[Deck](https://static.sched.com/hosted_files/owasp2023globalappsecwashin/2e/Global%20AppSec%202023%20-%20Fixing%20Broken%20Access%20Control%20-%20Omri%20Gazitt.pptx)

## Overview

This monorepo contains three projects:
* a react frontend for a Todo application (./todo-application)
* a node.js backend for the Todo application
* a harness for the Topaz authorizer, which itself includes three different variations of an authorization policy for the Todo backend

## Setting it up

Requirements:
* Docker running on your box (e.g. Docker desktop for Mac)
* `brew` (for mac or linux)
* `node` (we tested with v20 but it should work with anything >16)
* `yarn` (we tested with v1.22 but it should work with any v1)

Optional: 
* `go` v1.20+

If you have go installed, you can use the gRPC health probes in the `Makefile` for the Topaz section. We've commented those out in order to reduce the dependency list for getting a simple demo running.


We'll first set up the Topaz authorizer locally, and then build and run the backend and frontend.

### Topaz

```sh
cd ./topaz

# install topaz and policy CLIs
brew tap aserto-dev/tap && brew install topaz
brew tap opcr-io/tap && brew install policy

# run topaz install (gets the topaz container image)
make install

# build the policy locally using the policy CLI
make build-todo

# configure topaz with a local policy image and start it
make configure-local

# create the relationship model for the Todo app
make manifest

# import the data (Citadel users & groups - Rick & Morty)
make data

# run the test suite of authorization assertions
make test

# bring up the topaz console
make console
```

### Backend

Install the dependencies:

```sh
cd ./todo-node-js
yarn
```

Ensure you have the right `.env` file and run the server in dev mode on port 3001:

```sh
cp .env.example .env
yarn start
```

You should see the server running in `nodemon`.

### Frontend

Install the dependencies and run the react frontend on port 3000:

```sh
cd ./todo-application
yarn
yarn start
```

At this point, the frontend should show an OIDC login screen. You can login with the following users:
* rick@the-citadel.com
* morty@the-citadel.com
* beth@the-smiths.com
* summer@the-smiths.com
* jerry@the-smiths.com

Password for all: `V@erySecre#t123!`

See the [todo app repo](https://github.com/aserto-demo/todo-application) for more information about the Todo app.

## Switching policies

The default policy we built (`policy-todo`) is an attribute-based policy. It uses the `properties.roles[]` array to determine the role of the user.

There are two other policies we can use:
* `policy-todo-rebac`: uses relationships to groups instead of roles as properties of the user. This demonstrates using the Topaz built-in function `ds.check_relation` for evaluating the `member` relationship between a subject (`user`) and and object (`group`)
* `policy-todo-global-appsec`: utilizes the `todo` object type, permissions (`can_read`, `can_write`, `can_delete`), and relationships (`viewer`, `editor`, `owner`) to make the policy truly relationship-based.

#### policy-todo-rebac

```sh
# create the ReBAC policy for the todo app
make build-todo-rebac

# restart topaz
make restart
```
#### policy-todo-global-appsec

```sh
# create the ReBAC policy for the todo app
make build-todo-global-appsec

# restart topaz
make restart
```