import os
import sys

from sqlalchemy import create_engine, MetaData
from sqlalchemy import Column, text, insert
import sqlalchemy.types as T

from sqlalchemy.orm import declarative_base, Session

url = "mysql+pymysql://admin:123@129.0.0.3/practice"
engine = create_engine(url, echo=True)
session = Session(bind=engine)

Base = declarative_base()

class Station(Base):
    __tablename__ = "station"
    uid = Column(type_=T.String(36), name="UID", primary_key=True, default=text("(UUID())"), server_default=text("(UUID())"))
    id = Column(type_=T.Integer, name="ID")
    city = Column(type_=T.String(21), name="CITY")
    state = Column(type_=T.String(10), name="STATE")
    lat_n = Column(type_=T.Float, name="LAT_N")
    long_w = Column(type_=T.Float, name="LONG_W")

    def __init__(self, id, city, state, lat_n, long_w):
        super(Station).__init__()
        
        self.id = id
        self.city = city
        self.state = state
        self.lat_n = lat_n
        self.long_w = long_w


def create_tables():
    Base.metadata.create_all(engine)

def insert_data():
    dir = "hackerrank-weather-observation-station-20.txt"
    fd = os.open(dir, os.O_RDONLY)

    res = os.read(fd, os.path.getsize(dir)).splitlines()
    for line in res:
        spaces = line.decode("utf-8").split(" ")

        city = spaces[1]
        for i in range(2, len(spaces) - 1):
            if i + 1 >= len(spaces) or spaces[i + 1].replace('.', '', 1).isdigit():
                state = spaces[i]

                if i + 1 <= len(spaces) - 1 != None: lat_n = float(spaces[i + 1])
                if i + 2 <= len(spaces) - 1 != None: long_w = float(spaces[i + 2])
                break
            city += " " + spaces[i]
        
        session.add(Station(
            id=int(spaces[0]),
            city=city, state=state, lat_n=lat_n, long_w=long_w,
        ))
    session.commit()

# create_tables()
insert_data()