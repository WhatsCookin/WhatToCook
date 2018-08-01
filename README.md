# *What2Cook*

**What2Cook** Created by ORG WhatsCookin an iOS app that allows users to quickly view, recipes and start cooking! With Voice Command and text to speech to help read out instructions while cooking, anyone can use. Users can also use our “What’s In My Fridge” feature to discover recipes using only ingredients that they have in their fridge!

## User Stories

- [X] As a user, I want to be able to easily view recipes and all of the information associated with them, such as ingredients used, relative difficulty, time length, dietary restrictions, and instructions.
- [X] As a user, I want to be able to view all of these recipes in 2 forms, one at a time (single image) and all at once (collection view of images).
- [X] As a user, I want to be able to swipe left or right to quickly view receipes during Single view mode. 
- [X] As a user, I want to be able to discover new recipes using only the ingredients in my fridge or pantry.
- [X] As a user, I want to be able to filter through recipes based on ingredients, holidays, difficulty, dietary restrictions and time length.
- [X] As a user, I want to be able to bookmark certain recipes
- [X] As a user, I want a navbar to see my profile, bookmarks, settings, help, logout etc.
- [X] As a user, I want to be able to upload my own recipes and take a picture of my masterpiece!
- [X] As a user, I want to be able to add friends and see their recipes.
- [X] As a user, I want to be able to hear the instruction of the receipes read out loud ( TTS/ audio).



## Video Walkthrough
Here's a walkthrough of implemented user stories:

Search popular recipes:
https://i.imgur.com/vQ4W89e.gif

What's in my fridge:
https://i.imgur.com/nFd6xC7.gif

Bookmarks:
https://i.imgur.com/CQyYOaI.gif




## Nice To Haves
- [X] As a user, I want to be able to get recommendations on recipes using artificial intelligence
- [X] As a user, I want to be able to add friends via QR code
- [X] As a user, I want a tutorial when I first signup.
- [X] As a user, I want to see motivational quotes to eat healthier, cook at home, or take care of my health
- [X] As a user, I want  to be able to get feedback on my recipes, such as areas for improvement.
- [X] As a user, I want to be able to upload or attach pictures in comments or reviews.
- [X] As a user, I want a navbar to see my friends and news feed.
- [X] As a user, I want to be able to add friends and see their recipes.
- [X] As a user, I want to be able to live stream my cooking.







Layout Views:

1. Login/Signup - Similar to ParseChat Lab ( baby blue background and food icons in front)
1.5. First-Time Questionnaire/Tutorial (food preferences, allergies, experience level) - happens once, only for new users
2. Home Feed (all recipes, filterable)
    - Collection view mode (view of all recipes at once)
    - Single view mode (swipe to navigate and favorite/bookmark)
    - Filters (rating, difficulty, within time period)
    - Tab Bar (Single/Collection view, What’s in My Pantry?, Bookmarks)
    - Side Bar for Profile (What’s cooking?, My Pantry, Friends, Edit Profile, Settings)
3. Profile Feed (your recipes, recipes you commented on, etc.)
4. What’s My Fridge Feed
User can add ingredients to a checklist, which the app will automatically sort into categories (name, notes, picture, quantity)
    - “Select all” option (for all ingredients or a certain category)
    - Button for searching recipes with the checked ingredients (What to cook?)
    - User can save a set/list of ingredients to look up recipes next time / sorted by category
    - Able to select all/clear
5. Settings
Can enter food preferences, allergies, calories, etc. => will filter out feed accordingly
Log Out



Pen and Paper Wireframe:
https://drive.google.com/file/d/0BxLxl5vDUF8FT3RJeG4zT3ZjTV9mRGRZckdmNGFYdEVLZi1n/view?usp=sharing

Data Schema : 

User
    - Email: String
    - password : String
    - name : String
    - displayName: String
    - Friends [ user references/ ids  ] (optional) 
    - Bookmarked : [recipes references/ ids]  

Ingredents
    - Catagory : String
    - Name : String
    - inclued : Boolean

 
 Recipe 
    - rating : int
    - time length : int
    - difficulty : int 
    - name : string 
    - Description : blog/ clob
    - Directions : String
    - ingredients :[ ingredients references/ ids ]
    - image: image
    - bookmark count : int 
    - reviews [comments/post reference] (optional)
    
Optional Tables 

 Comment / Post 
    - User 
    - Description 
    - Picture 
    - link to recipes ( recipe object/ recipe ids ) 
    - likes_count : int 
    
    
    

