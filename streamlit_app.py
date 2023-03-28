
import streamlit
import pandas
import requests 
import snowflake.connector
from urllib.error import URLError

streamlit.header('Breakfast Menu')
streamlit.text('🧇 Omega 3 & Blueberry Oatmeal')
streamlit.text('🥬 Kale, Spinach & Rocket Smoothie')
streamlit.text('🍗 Hard-Boiled Free-Range Egg')
streamlit.text('🥑 Avacado')

streamlit.header('🍌🥭 Build Your Own Fruit Smoothie 🥝🍇')
#import pandas
my_fruit_list = pandas.read_csv("https://uni-lab-files.s3.us-west-2.amazonaws.com/dabw/fruit_macros.txt")
my_fruit_list = my_fruit_list.set_index('Fruit')

# Lets put a pick list here so they can pick the fruit they want to include
fruits_selected = streamlit.multiselect("Pick some fruits:", list(my_fruit_list.index), ['Avocado', 'Strawberries'])

#To debug issue
#streamlit.write("Printing fruits selected")
#streamlit.write(*fruits_selected)

fruits_to_show = my_fruit_list.loc[fruits_selected]

# Display the table on the Page
streamlit.dataframe(fruits_selected)

#Create function
def get_fruityvice_data(this_fruit_choice):
    fruityvice_response = requests.get('https://fruityvice.com/api/fruit/' + fruit_choice)
    #take the json version of response and normalize it
    fruityvice_normalized = pandas.json_normalize(fruityvice_response.json())
    return fruityvice_normalized
#New Section to display FruityVice api response
streamlit.header('Fruityvice Fruit Advice')
try:
  #take input from user
  fruit_choice = streamlit.text_input('What fruit do you like information about', 'kiwi')
  if not fruit_choice:
    streamlit.error('Please select a fruit to get information')
  else:
    back_from_func = get_fruityvice_data(fruit_choice)
    #output it on the screen as a table
    streamlit.dataframe(back_from_func)
except URLError as e:
  streamlit.error()
    
streamlit.header("View Our Fruit List - Add your Favorites!")
#Snowflake related functions
def get_fruit_load_list():
    with my_cnx.cursor() as my_cur:
        my_cur.execute("select * from FRUIT_LOAD_LIST")
        return my_cur.fetchall()
#Add button to load the fruit
if streamlit.button('Get Fruit list'):
    my_cnx = snowflake.connector.connect(**streamlit.secrets["snowflake"])
    my_data_row = get_fruit_load_list()
    my_cnx.close()
    streamlit.dataframe(my_data_row)

#streamlit.stop()
#Allow the end user to add a fruit to the list
def insert_row_snowflake(new_fruit):
    with my_cnx.cursor() as my_cur:
        my_cur.execute("insert into fruit_load_list values('"+ new_fruit +"')")
        return "Thanks for adding "+ new_fruit

#take second input from user
fruit_to_add = streamlit.text_input('What fruit would you like to add?')
if streamlit.button('Add a Fruit to the list'):
    my_cnx = snowflake.connector.connect(**streamlit.secrets["snowflake"])
    back_from_func = insert_row_snowflake(fruit_to_add)
    my_cnx.close()
    streamlit.text(back_from_func)
    
#my_cur.execute("insert into fruit_load_list values('from streamlit')")