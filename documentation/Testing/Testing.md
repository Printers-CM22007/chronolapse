[Back](../../README.md)

# Testing

To run all tests, merge their coverage reports, then show them run
```bash
python test.py
```

To run an individual test run
```bash
python test.py path/to/test
```

If you want to use a specific shell to run commands, e.g. fish, run
```bash
python test.py [all|path/to/test] fish
```

... then to view the coverage report
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

