from sqlalchemy import create_engine, exc
from sqlalchemy.orm import sessionmaker
from sqlalchemy.dialects.postgresql import insert

from api.exceptions import DataError, ObjectNotDefinedError

from models import SampleIdGeneration
from models import DataSource

class ImportSession():
  """
  Creates session with the DB for import
  """

  def __init__(self, database, echo_debug=False):
    #dbschema = 'Config,public'  # Searches left-to-right
    #self.engine = create_engine(database, connect_args={'options': '-csearch_path={}'.format(dbschema)}, echo=echo_debug) # this cannot add schema
    self.engine = create_engine(database, echo=echo_debug)
    self.Session = sessionmaker(bind=self.engine, expire_on_commit=False)

  def get(self):
    return Import(self)

class Import():
  def __init__(self, db):
    self.db = db

  def __enter__(self):
    self.session = self.db.Session()
    return self

  def __exit__(self, exec_type, exec_value, traceback):
    self.session.close()

  def registerDataSource(self, project, ds_name, ds_description):
    datasource = None
    try:
      datasource = DataSource(Project = project,
                                DataSource = ds_name,
                                DataSourceDescription = ds_description)
      self.session.add(datasource)
      self.session.commit()
    except Exception as e:
      self.session.rollback()
      raise DataError(e)

    return datasource

  def registerSampleIdGeneration(self, ds_id, ext_id):
    stmt = insert(SampleIdGeneration).values({'DataSourceKey': ds_id, 'SourceSampleId': ext_id})
    do_nothing_stmt = stmt.on_conflict_do_nothing()
    # if a record already exists, stmt execution will give error, but on_conflict_do_nothing will do nothing
    # the error is triggered by the sampleidgeneration.py's sa.UniqueConstraint('DataSourceKey', 'SourceSampleId', name='ucpy1'),

    result = self.session.execute(do_nothing_stmt).inserted_primary_key

    return result
