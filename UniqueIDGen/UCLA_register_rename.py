#!/usr/bin/env python

import sys
import getopt
import vcf

from os import path
from api import ImportSession
from models import DataSource

def add_database_VCF(datasource_name, ext_id, db_url, code_path, output_path):
    #sys.path.append(path.abspath('/Users/yp/Google Drive/think for mac/ucla_health/ucla/atlas/UniqueIDGen'))
    sys.path.append(path.abspath(code_path))

    print "datasource_name:"+datasource_name
    print "ext_id: "+ext_id

    #Register the new sequencing data into the postgres database.
    try:
        with ImportSession(db_url).get() as session:
            ds_id = session.session.query(DataSource).filter(DataSource.DataSource == datasource_name).first()
            print "========================"+str(ds_id.DataSourceKey)
            print "++++++++++++++++++++++++"+str(ext_id)
            genomicsdbid = session.registerSampleIdGeneration(ds_id=ds_id.DataSourceKey, ext_id=ext_id)
            session.session.commit()

        if genomicsdbid is not None:
            #with open("/scratch/{datasource}-{ext_id}-postname.txt".format(datasource=datasource_name, ext_id=ext_id), 'w') as postname:
            #with open("/Users/yp/Downloads/atlas/test/{datasource}-{ext_id}-postname.txt".format(datasource=datasource_name, ext_id=ext_id), 'w') as postname:
            with open("{output_path}/{datasource}-{ext_id}-postname.txt".format(output_path=output_path, datasource=datasource_name, ext_id=ext_id), 'w') as postname:

                postname.write("{datasource}-{ext_id}".format(datasource=datasource_name, ext_id=ext_id.strip()))

                # For example, gtc_file="204236570048_R12C02.gtc"
                # ext_id=${gtc_file%%.*}, which remove the extension of the gtcfile, namely, ext_id="204236570048_R12C02"
                # So the unique id is atlas-204236570048_R12C02

        else:
            print "already uploaded datasource= {datasource} ds_id= {ds_id} ext_id= {ext_id} ".format(datasource=datasource_name, ds_id=ds_id.DataSourceKey, ext_id=ext_id)
            sys.exit(2)

    except Exception as e:
        print "Adding into DB failed because of %s" % e
        print 'Error on line {}'.format(sys.exc_info()[-1].tb_lineno) + " " + type(e).__name__
        sys.exit(2)

def registerDataSource(project, database_name, data_desc, data_extid_desc, db_url="postgresql://@:5432/testimport"):

    try:
        with ImportSession(db_url).get() as session:  # ImportSession defines how to connect to db and how to operate tables
            datasource = session.registerDataSource(Project = project,
                                                    DataSource = database_name,
                                                    DataSourceDescription = data_desc)
    except Exception as e:
        print "Registering data source failed because of %s" % (e)
        print 'Error on line {}'.format(sys.exc_info()[-1].tb_lineno) + " " + type(e).__name__
        sys.exit(2)


if __name__ == "__main__":

    try:
        opts, args = getopt.getopt(sys.argv[1:], ":h", ["command=", "project=", "database_name=", "data_desc=", "data_extid_desc=",
                                                      "db_url=", "vcf_path=", "ext_id=", "outputVCFpath=", "code_path=", "output_path="])
    except getopt.GetoptError as e:
        print "Error: " + str(e)
        sys.exit(2)

    param_dict = dict(opts)

    if param_dict.get("-h", None) != None:
        print """This script is used to rename VCFs and insert into a GenomicsDB Postgres database for ID management.
This script is also used to register a datasource for the GenomicsDB ID management."""
        sys.exit()

    elif param_dict.get("--command", None) == None:
        print """ ** No Command Specified ! **
Usage to register: UCLA_register_rename.py --command register --database_name <database_name> --data_desc <data_description> --data_extid_desc <externalID_description> --db_url <db_url>
Usage to rename: UCLA_register_rename.py --command rename --database_name <databaseName> --vcf_path <vcfpath> --ext_id <newSampleName> --outputVCFpath <outputFilePath> --db_url <db_url>        			  """

    elif param_dict.get("--command") == "register":
        registerDataSource(project =param_dict.get("--project"),
                           database_name=param_dict.get("--database_name"),
                           data_desc=param_dict.get("--data_desc"),
                           data_extid_desc=param_dict.get("--data_extid_desc"),
                           db_url=param_dict.get("--db_url")
                           )
    elif param_dict.get("--command") == "rename":
        add_database_VCF(datasource_name=param_dict.get("--database_name"),
                         ext_id=param_dict.get("--ext_id"),
                         db_url=param_dict.get("--db_url"),
                         code_path=param_dict.get("--code_path"),
                         output_path=param_dict.get("--output_path")
                         )
    else:
        pass
