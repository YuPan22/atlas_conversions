
from sqlalchemy.ext.declarative import declarative_base

_Base = declarative_base()

from .datasource import DataSource
from .sampleidgeneration import SampleIdGeneration

def bind_engine(engine):
    _Base.metadata.create_all(engine)
