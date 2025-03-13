flutter test --coverage

mv coverage/lcov.info coverage/lcov-unit.info

flutter test integration_test/ --coverage

mv coverage/lcov.info coverage/lcov-integration.info

lcov --add-tracefile coverage1.info -a lcov-integration.info -o lcov-combined.info
