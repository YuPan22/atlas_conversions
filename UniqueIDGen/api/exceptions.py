import traceback

class DataError(Exception):
  def __init__(self, value):
    self.value = "DataError {0}".format(str(value))
  def __str__(self):
    return repr(self.value)

class ObjectNotDefinedError(Exception):
  def __init__(self, model, identifier):
    self.value = "The {0} object with {1} is not defined".format(model, identifier)
  def __str__(self):
    return repr(self.value)
