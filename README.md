<p align="center">
  <a href="./ergo.png">
    <img src="./ergo.png" alt="Ergo logo">
  </a>
</p>

![Build Status](https://travis-ci.org/accordproject/ergo.svg?branch=master)
![CircleCI](https://circleci.com/gh/accordproject/ergo.svg?style=shield)
[![Coverage Status](https://coveralls.io/repos/github/accordproject/ergo/badge.svg?branch=master)](https://coveralls.io/github/accordproject/ergo?branch=master)
[![GitHub license](https://img.shields.io/github/license/accordproject/ergo?color=bright-green)](https://github.com/accordproject/ergo/blob/master/LICENSE)
[![downloads](https://img.shields.io/npm/dm/@accordproject/ergo-cli)](https://www.npmjs.com/package/@accordproject/ergo-cli)
[![npm version](https://badge.fury.io/js/%40accordproject%2Fergo-cli.svg)](https://badge.fury.io/js/%40accordproject%2Fergo-cli)
![lerna](https://img.shields.io/badge/maintained%20with-lerna-cc00ff.svg)
[![Netlify Status](https://api.netlify.com/api/v1/badges/8b6ef766-c6d0-45bb-bff6-03104e6ff913/deploy-status)](https://app.netlify.com/sites/ergorepl/deploys)
[![join slack](https://img.shields.io/badge/Slack-Join%20Slack-blue)](https://accord-project-slack-signup.herokuapp.com/)


## About

This is the source code for the Ergo compiler. Ergo is the [Accord Project][apmain]
language for Smart Legal Contracts.

The Ergo compiler is distributed as an [npm package][npmpkg]. 

The Ergo compiler is written using the [Coq][coq] proof assistant, with parsing and
support code written in [OCaml][OCaml]. It makes extensive use
of the [Q*cert compiler][Qcert] for code generation and type checking.

Both the Ergo language and its compiler are in early development
phase. If you would like to build from source or to contribute,
consult the [DEVELOPERS][developers] file.

## Try Ergo online

If you want to take a peek at Ergo without installing anything, check
out the interactive [REPL][REPL]
(read-eval-print-loop) for Ergo stand-alone, or the [Accord Project Template Studio][studio] 
which illustrates Ergo in Accord Project templates.

## Documentation

The most recent Ergo documentation is in the [Ergo Language Guide][docergo].

## Quickstart

### Install Ergo

The easiest way to install Ergo is as a [Node.js][nodejs] package.
Once you have Node.js installed on your machine, you can get the Ergo compiler
and command-line using the Node.js package manager by typing the following in a
terminal:

```sh
$ npm install -g @accordproject/ergo-cli
```

This will install the Ergo command-line (`ergo`) and Read-Eval-Print-Loop (`ergotop`). Those will allow you to create, test and compile Ergo contracts. You can check your installed version by typing the following in a terminal:

```sh
$ ergo --version
```

Or to get command line help:

```sh
$ ergo --help
ergo <command>

Commands:
  ergo draft       create a contract text from data
  ergo request     send a request to the contract
  ergo invoke      invoke a clause of the contract
  ergo initialize  initialize the state for a contract
  ergo compile     compile a contract

Options:
  --help         Show help                                             [boolean]
  --version      Show version number                                   [boolean]
  --verbose, -v                                                 [default: false]
```

### Create contract text

To create a contract text from a contract:

```sh
$ ergo draft --template ./examples/volumediscount --data ./examples/volumediscount/data.json
```

### Initialize a contract

To obtain the initial state of the contract:

```sh
$ ergo initialize --template ./examples/volumediscount --data ./examples/volumediscount/data.json
06:40:29 - info:
```

### Send a request

To send a request to a contract:

```sh
$ ergo  request --template ./examples/volumediscount --data ./examples/volumediscount/data.json --request ./examples/volumediscount/request.json --state ./examples/volumediscount/state.json
06:40:01 - info:
{
  "clause": "orgXaccordprojectXvolumediscountXVolumeDiscount",
  "request": {
    "$class": "org.accordproject.volumediscount.VolumeDiscountRequest",
    "netAnnualChargeVolume": 10.4
  },
  "response": {
    "$class": "org.accordproject.volumediscount.VolumeDiscountResponse",
    "discountRate": 2.8,
    "transactionId": "13fa7cb6-03fc-4fd8-8e12-9a85ac8d5eb7",
    "timestamp": "2019-10-12T23:56:33.688Z"
  },
  "state": {
    "$class": "org.accordproject.cicero.contract.AccordContractState",
    "stateId": "1"
  },
  "emit": []
}
```

### Invoke a clause

To invoke a specific clause of the contract:

```sh
$ ergo invoke --template ./examples/volumediscount --clauseName volumediscount --data ./examples/volumediscount/data.json --params ./examples/volumediscount/params.json --state ./examples/volumediscount/state.json
```

### Compile a contract

To compile your first Ergo contract to JavaScript:

```sh
$ ergo compile ./examples/volumediscount/model/model.cto ./examples/volumediscount/logic/logic.ergo
Processing file: ./examples/volumediscount/logic.ergo -- compiled to: ./examples/volumediscount/logic.js
```

By default, Ergo compiles to JavaScript for execution. You can inspect
the compiled JavaScript code in `./examples/volumediscount/logic.js`

---

<p align="center">
  <a href="https://www.accordproject.org/">
    <img src="assets/APLogo.png" alt="Accord Project Logo" width="400" />
  </a>
</p>

Accord Project is an open source, non-profit, initiative working to transform contract management and contract automation by digitizing contracts. Accord Project operates under the umbrella of the [Linux Foundation][linuxfound]. The technical charter for the Accord Project can be found [here][charter].

## Learn More About Accord Project

### Overview
* [Accord Project][apmain]
* [Accord Project News][apnews]
* [Accord Project Blog][apblog]
* [Accord Project Slack][apslack]
* [Accord Project Technical Documentation][apdoc]
* [Accord Project GitHub][apgit]


### Documentation
* [Getting Started with Accord Project][docwelcome]
* [Concepts and High-level Architecture][dochighlevel]
* [How to use the Cicero Templating System][doccicero]
* [How to Author Accord Project Templates][docstudio]
* [Ergo Language Guide][docergo]

## Contributing

The Accord Project technology is being developed as open source. All the software packages are being actively maintained on GitHub and we encourage organizations and individuals to contribute requirements, documentation, issues, new templates, and code.

Find out what’s coming on our [blog][apblog].

Join the Accord Project Technology Working Group [Slack channel][apslack] to get involved!

For code contributions, read our [CONTRIBUTING guide][contributing] and information for [DEVELOPERS][developers].

## License <a name="license"></a>

Accord Project source code files are made available under the [Apache License, Version 2.0][apache].
Accord Project documentation files are made available under the [Creative Commons Attribution 4.0 International License][creativecommons] (CC-BY-4.0).

Copyright 2018-2019 Clause, Inc. All trademarks are the property of their respective owners. See [LF Projects Trademark Policy](https://lfprojects.org/policies/trademark-policy/).

[apmain]: https://accordproject.org/ 
[apworkgroup]: https://calendar.google.com/calendar/event?action=TEMPLATE&tmeid=MjZvYzIzZHVrYnI1aDVzbjZnMHJqYmtwaGlfMjAxNzExMTVUMjEwMDAwWiBkYW5AY2xhdXNlLmlv&tmsrc=dan%40clause.io
[apblog]: https://medium.com/@accordhq
[apnews]: https://www.accordproject.org/news/
[apgit]:  https://github.com/accordproject/
[apdoc]: https://docs.accordproject.org/
[apslack]: https://accord-project-slack-signup.herokuapp.com

[docspec]: https://docs.accordproject.org/docs/spec-overview.html
[docwelcome]: https://docs.accordproject.org/docs/accordproject.html
[dochighlevel]: https://docs.accordproject.org/docs/spec-concepts.html
[docergo]: https://docs.accordproject.org/docs/logic-ergo.html
[docstart]: https://docs.accordproject.org/docs/accordproject.html
[doccicero]: https://docs.accordproject.org/docs/basic-use.html
[docstudio]: https://docs.accordproject.org/docs/advanced-latedelivery.html

[contributing]: https://github.com/accordproject/ergo/blob/master/CONTRIBUTING.md
[developers]: https://github.com/accordproject/ergo/blob/master/DEVELOPERS.md

[linuxfound]: https://www.linuxfoundation.org
[charter]: https://github.com/accordproject/ergo/blob/master/CHARTER.md
[npmpkg]: https://www.npmjs.com/package/@accordproject/ergo-cli
[coq]: https://coq.inria.fr
[OCaml]: https://ocaml.org
[Qcert]: https://querycert.github.io
[REPL]: https://ergorepl.netlify.com
[studio]: https://studio.accordproject.org
[nodejs]: https://nodejs.org/

[apache]: https://github.com/accordproject/ergo/blob/master/LICENSE
[creativecommons]: http://creativecommons.org/licenses/by/4.0/
