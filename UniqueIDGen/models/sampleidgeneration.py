from . import _Base
import sqlalchemy as sa
from sqlalchemy.schema import Sequence
from sqlalchemy.sql import func

class SampleIdGeneration(_Base):
  #_Base.metadata.schema = 'Config'   # this defines the schema
  _Base.metadata.schema = 'eiada_Config'
  __tablename__ = "SampleIdGeneration"
  SN_id_seq = Sequence('SN_id_seq', metadata=_Base.metadata, minvalue=0, start=0)  # SN_id_seq is an object, I can modify its value in pgadmin.
  #UniqueSampleId = sa.Column('UniqueSampleId', sa.BigInteger, Sequence('SN_id_seq'), primary_key=True)
  UniqueSampleId = sa.Column('UniqueSampleId', sa.BigInteger, SN_id_seq, primary_key=True)
  #UniqueSampleId = sa.Column('UniqueSampleId', sa.BigInteger, primary_key=True)
  DataSourceKey = sa.Column('DataSourceKey', sa.Integer, sa.ForeignKey('DataSource.DataSourceKey'), nullable=False)
  SourceSampleId = sa.Column('SourceSampleId', sa.Text, nullable=False)
  DateCreated = sa.Column('DateCreated', sa.DateTime(timezone=True), server_default=func.now())

  __table_args__ = (
    sa.UniqueConstraint('DataSourceKey', 'SourceSampleId', name='ucpy1'), # 'DataSourceKey' and 'SourceSampleId' together should be unique
    sa.ForeignKeyConstraint(['DataSourceKey'],['DataSource.DataSourceKey']),
  )
