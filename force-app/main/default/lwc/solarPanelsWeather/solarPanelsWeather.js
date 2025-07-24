import { LightningElement, wire, track } from 'lwc';
import getCurrentWeatherForInstallations from '@salesforce/apex/SolarPanelsWeatherController.getCurrentWeatherForInstallations';
import getForecastWeatherForInstallations from '@salesforce/apex/SolarPanelsWeatherController.getForecastWeatherForInstallations';
import getDistinctCountries from '@salesforce/apex/SolarPanelsWeatherController.getDistinctCountries';
import getDistinctCities from '@salesforce/apex/SolarPanelsWeatherController.getDistinctCities';
import getInstallations from '@salesforce/apex/SolarPanelsWeatherController.getInstallations';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SolarPanelsWeather extends LightningElement {
    
    columns = [
        { label: 'Date', fieldName: 'dateFormatted' },
        { label: 'Min (°C)', fieldName: 'mintemp_c', type: 'number' },
        { label: 'Max (°C)', fieldName: 'maxtemp_c', type: 'number' },
        { label: 'Avg (°C)', fieldName: 'avgtemp_c', type: 'number' },
        { label: 'Sunrise', fieldName: 'sunrise' },
        { label: 'Sunset', fieldName: 'sunset' }
    ];

    @track mapMarkers = [];
    @track installations = [];
    @track selectedCountry = '';
    @track selectedCity = '';
    @track countryOptions = [];
    @track cityOptions = [];
    @track forecastData = [];
    showTable = false;

    isModalOpen = false;
    currentMarker;
    error;

    connectedCallback() {
        getDistinctCountries().then(result => {
            this.countryOptions = result.map(c => ({ label: c, value: c }));
        });
    }

    handleCountryChange(event) {
        this.selectedCountry = event.detail.value;
        getDistinctCities({ country: this.selectedCountry }).then(result => {
            this.cityOptions = result.map(c => ({ label: c, value: c }));
        });
    }

    handleCityChange(event) {
        this.selectedCity = event.detail.value;
    }

    handleSearch() {
        getInstallations({ country: this.selectedCountry, city: this.selectedCity }).then(result => {
            console.log(JSON.stringify(result));
            this.installations = result.map(el => ({
                id:          el.Id,
                accountName: el.Account__r?.Name,
                street:      el.Street__c,
                city:        el.City__c,
                state:       el.State__c,
                date:        el.InstallationDate__c,
                lastupdate:  el.WeatherLastUpdate__c,
                condition:   el.WeatherCondition__c,
                ftemperature: el.FTemperature__c,
                ctemperature: el.CTemperature__c,
                iconUrl:     el.ConditionIconURL__c
            }));

            this.mapMarkers = this.installations.map(inst => ({
                location: {
                    Street: inst.street,
                    City:   inst.city,
                    State:  inst.state
                },
                title:       inst.accountName,
                description: `Installed on ${inst.date}`,
                value: inst.id
            }));
        });
    }

    getCurrentWeather(){
        console.log(this.currentMarker.id);
        getCurrentWeatherForInstallations({
            installationId: this.currentMarker.id
        }).then(result => {
            console.log(result);
            const weatherData = JSON.parse(result);
            this.currentMarker = {
                ...this.currentMarker,
                iconUrl: 'https:' + weatherData.current.condition?.icon,
                condition: weatherData.current.condition?.text,
                ftemperature: weatherData.current.temp_f,
                ctemperature: weatherData.current.temp_c,
                lastupdate: weatherData.current.last_updated
            };
        }).catch(error => {
            console.log(error);
            const message = error?.body?.message || error.message || 'unknown error';

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error getting weather current',
                    message: message,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        });
    }

    getForecastWeather(){
        console.log(this.currentMarker.id);
        getForecastWeatherForInstallations({
            installationId: this.currentMarker.id
        }).then(result => {
            this.forecastData = [];
            this.showTable = true;
            const forecastResult = JSON.parse(result);
            this.forecastData = forecastResult.forecast.forecastday.map((day, index) => ({
                id: index,
                dateFormatted: this.convertEpochToDate(day.date_epoch),
                mintemp_c: day.day.mintemp_c,
                maxtemp_c: day.day.maxtemp_c,
                avgtemp_c: day.day.avgtemp_c,
                sunrise: day.astro.sunrise,
                sunset: day.astro.sunset
            }));
            this.error = null;
            
        }).catch(error => {
            console.log(error);
            const message = error?.body?.message || error.message || 'unknown error';

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error getting weather forecast',
                    message: message,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        });
    }

    handleMarkerSelect(event) {
        const marker = event.detail.selectedMarkerValue;
        console.log(this.installations);
        this.currentMarker = this.installations.find(inst => inst.id === marker);
        this.openModal();
    }

    convertEpochToDate(epoch) {
        const date = new Date(parseInt(epoch, 10) * 1000);
        return date.toLocaleDateString('en-US');
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.showTable = false;
    }
}