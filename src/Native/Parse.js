var _user$project$Native_Parse = (function() {
  // HELPERS

  function ok(index, value) {
    return { ctor: 'Ok', _0: { index: index, value: value } };
  }

  function err(msg) {
    return { ctor: 'Err', _0: msg };
  }

  // BASICS

  function succeed(value) {
    return function(input, index) {
      return ok(index, value);
    };
  }

  function fail(msg) {
    return function(input, index) {
      return err(msg);
    };
  }

  // SATISFY

  function satisfy(isOk) {
    return function(input, index) {
      if (input.length <= index) {
        return err('ran out of characters');
      }
      var chr = _elm_lang$core$Native_Utils.chr(input[index]);
      return isOk(chr)
        ? ok(index + 1, chr)
        : err(
            "char '" + input[index] + "' at index " + index + ' is not okay.'
          );
    };
  }

  function string(expected) {
    return function(input, index) {
      var nextIndex = index + expected.length;
      var actual = input.slice(index, nextIndex);
      return expected === actual
        ? ok(nextIndex, actual)
        : err(
            "expecting '" +
              expected +
              "' at index " +
              index +
              " but instead saw '" +
              actual +
              "'."
          );
    };
  }

  // ONE OF

  function oneOf(parserList) {
    var parsers = _elm_lang$core$Native_List.toArray(parserList);

    return function(input, index) {
      var len = parsers.length;
      for (var i = 0; i < len; ++i) {
        var result = parsers[i](input, index);
        if (result.ctor === 'Ok') {
          return result;
        }
      }
      return err('none of the parsers given to oneOf worked');
    };
  }

  // AND THEN

  function andThen(callback, parser) {
    return function(input, index) {
      var result = parser(input, index);
      if (result.ctor === 'Ok') {
        var newData = result._0;
        return callback(newData.value)(input, newData.index);
      } else {
        return result;
      }
    };
  }

  // RUN

  function run(parser, input) {
    var result = parser(input, 0);
    if (result.ctor === 'Ok') {
      return { ctor: 'Ok', _0: result._0.value };
    } else {
      return result;
    }
  }

  return {
    succeed: succeed,
    fail: fail,
    satisfy: satisfy,
    string: string,
    oneOf: oneOf,
    andThen: F2(andThen),
    run: F2(run),
  };
})();
