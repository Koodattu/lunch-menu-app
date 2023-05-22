<div align="center">
    <img src="https://i.imgur.com/YzqFU2A.png" alt="Logo" width="80" height="80">

  <h3 align="center">Lunch Menu Application</h3>

  <p align="center">
   A lunch menu application with flutter and spring boot. 
    <br />
    <br />
  </p>
</div>

## Project description

A full-stack application for viewing a staff restaurant's weekly lunch menu with extra features, like voting and history of past weeks. 
Frontend made for mobile devices with flutter and written in dart. Backend made with spring boot and written in java. 

![](https://i.imgur.com/90eGpV0.png)
![](https://i.imgur.com/ft5LKnI.png)

Backend fetches the menu as a Microsoft Word .doc file from Google Drive, parses it and saves it to a PostgreSQL database. The Google Drive file is checked a few times a day for updated menu. Communication between backend and frontend is handled via REST-api requests in json format.

### Features
* Current week's lunch menu
* History of all previous weeks
* Voting for courses in likes, dislikes and a "ranked" -style 
* Supports both english and finnish languages with a toggle in app settings

## Authors

Juha Ala-Rantala ([Koodattu](https://github.com/Koodattu/))

## Version History

* 1.0.0
    * Initial release

## License

Distributed under the MIT License. See `LICENSE` file for more information.

## Acknowledgments

* [pub.dev](https://pub.dev/)
* [icons8](https://icons8.com/)
* [quicktype](https://app.quicktype.io/)
* [Baeldung](https://www.baeldung.com/)
* [dribbble](https://dribbble.com/)
