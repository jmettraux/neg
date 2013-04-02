
# neg - CHANGELOG.md


## neg - 1.2.0    not yet released

- turn CharacterParser into RegexParser, don't get in the way of scan_regex
- stop tracking (offset, column, line), simply track offset in result tree
- implement Parser.recursive?
- simplify Parser.to_s


## neg - 1.1.0    released 2013-02-28

- giving the "right" error on unconsumed input
- get rid of UnconsumedInputError
- translator: introduce n.flattened_results


## neg - 1.0.0    released 2013-01-16

- initial release

