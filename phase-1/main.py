from typing import Optional
from fastapi import FastAPI, HTTPException, status
from pydantic.main import BaseModel
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()

Instrumentator().instrument(app).expose(app)

CAR_DB = {}
car_id_counter = 1

class Car(BaseModel):
    make: str
    model: str
    year: int
    color: Optional[str] = None

class CarOut(Car):
    id: int

@app.get("/")
async def root():
    return {"message": "Hello World!"}

# Health Check
@app.get("/liveness")
async def liveness():
    return {"message": "now live!"}

@app.get("/readiness")
async def readiness():
    return {"message": "ready!"}

# CRUD ENDPOINTS
@app.post("/cars", status_code=status.HTTP_201_CREATED)
async def create_car(car: Car):
    global car_id_counter

    car_dict = car.model_dump()
    car_dict["id"] = car_id_counter

    CAR_DB[car_id_counter] = car_dict
    car_id_counter += 1
    return car_dict

# 2. READ (Get All)
@app.get("/cars")
async def get_all_cars():
    return list(CAR_DB.values())

# 3. READ (Get One by ID)
@app.get("/cars/{car_id}")
async def get_car(car_id: int):
    if car_id not in CAR_DB:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=f"Car with ID {car_id} not found"
        )
    return CAR_DB[car_id]

@app.put("/cars/{car_id}")
async def update_car(car_id: int, updated_car: Car):
    if car_id not in CAR_DB:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=f"Car with ID {car_id} not found"
        )
    
    car_dict = updated_car.model_dump()
    car_dict["id"] = car_id
    CAR_DB[car_id] = car_dict
    return car_dict

# 5. DELETE
@app.delete("/cars/{car_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_car(car_id: int):
    if car_id not in CAR_DB:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=f"Car with ID {car_id} not found"
        )
    del CAR_DB[car_id]
    return None
