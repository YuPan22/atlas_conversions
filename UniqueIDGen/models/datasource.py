from . import _Base
import sqlalchemy as sa
from sqlalchemy.schema import Sequence
from sqlalchemy.sql import func

class DataSource(_Base):
  #_Base.metadata.schema = 'Config'
  _Base.metadata.schema = 'eiada_Config'
  __tablename__ = "DataSource"
  DataSrcID_seq = Sequence('DataSrcID_seq', minvalue=0, start=0)
  DataSourceKey = sa.Column('DataSourceKey', sa.Integer, Sequence('DataSrcID_seq'), primary_key=True)
  Project = sa.Column('Project', sa.Text, nullable=False)
  DataSource = sa.Column('DataSource', sa.Text, nullable=False)
  DataSourceDescription = sa.Column('DataSourceDescription', sa.Text)
  DateCreated = sa.Column('DateCreated', sa.DateTime(timezone=True), server_default=func.now())
