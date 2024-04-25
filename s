from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
import requests
import json
import random
from collections import OrderedDict

# ---------------------------------------------
# uzd 1

app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False



@app.route('/joke', methods=['GET'])
def show_joke():
    response = requests.get("https://official-joke-api.appspot.com/random_joke")
    result = json.loads(response.text)
    punch_line = result.get("setup")
    setup = result.get("punchline")
   
    return jsonify({punch_line:setup}) 
# ---------------------------------------------
# uzd 2 
riddle1 = {
    "Riddle": "A girl fell off a 20-foot ladder. She wasn’t hurt. How",
    "Answer": "She fell off the bottom step"
}

riddle2 = {
    "Riddle": "You’re in a race and you pass the person in second place. What place are you in now?",
    "Answer": "Second place"
}

riddle_list = [riddle1,riddle2]


@app.route('/riddle', methods=['GET'])
def show_riddle():
    riddle_user = random.choice(riddle_list)
    punch_line = riddle_user.get("Riddle")
    setup = riddle_user.get("Answer")
    return jsonify({punch_line:setup}) 
# ---------------------------------------------
# uzd 3 

@app.route('/sum', methods=['POST'])
def show_sum():
    numbers_sum = request.json['numbers']
    result = sum(numbers_sum)
    return jsonify({"Result":result}) 
# ---------------------------------------------
# uzd 4

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///MovieAPI.db' 

db = SQLAlchemy(app)
ma = Marshmallow(app)

class Movie(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column('Title', db.String)
    genre = db.Column('Genre', db.String)
    rating = db.Column('Rating', db.Float)

class MovieSchema(ma.Schema):
    class Meta:
        fields = ('id','title','genre','rating')
    
Movie_schema = MovieSchema()
Movie_schemas = MovieSchema(many=True)

with app.app_context():
    db.create_all()

@app.route('/add_movie', methods=['POST'])
def add_product():
    title = request.json['Title']
    genre = request.json['Genre']
    rating = request.json['Rating']
    if((title != " ") and (genre!= " ") and (rating != None)): # primityvus budas tikrinti... 
        new_movie = Movie(title=title, genre=genre, rating=rating)
        db.session.add(new_movie)
        db.session.commit()
        return Movie_schema.jsonify(new_movie)
    else:
        return jsonify({"Please check all imputs": "Error"})

@app.route('/get_suggestions', methods=['GET']) # nespejau sitos 
def get_suggestions():
    all_movies =  Movie.query.all()
    return_movies = []
    if all_movies:
        sorted_result = sorted(all_movies, key=lambda x: x.rating, reverse=True)
        top_three = sorted_result[:3]
        return_movies = []
        for o_movie in top_three:
            return_movies.append(o_movie.id)
        elements = Movie.query.filter(Movie.id.in_(return_movies)).all()
        result = [{'id': element.id, 'Title': element.title, 'Genre':element.genre, 'Rating': element.rating} for element in elements]
        return jsonify(result)
    else:
        return jsonify({"Error":"no movies in the database"}) 




if __name__ == '__main__':
    app.run(debug=True)


# ----------------------------- Test side

movie = {
    "Title": "Crime 1",
    "Genre": " ",
    "Rating": 9 
}




import requests
import json


#response = requests.get('http://127.0.0.1:/joke')
#response = requests.get('http://127.0.0.1:/riddle')
#response = requests.post('http://127.0.0.1:/sum', json=numbers)
#response = requests.post('http://127.0.0.1:/add_movie', json=movie)
response = requests.get('http://127.0.0.1:/get_suggestions')
result = json.loads(response.text)
print(result)    
