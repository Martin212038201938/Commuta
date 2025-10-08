// DOM Elements
const screens = {
    home: document.getElementById('home-screen'),
    addDestination: document.getElementById('add-destination-screen'),
    destinationPicker: document.getElementById('destination-picker-screen'),
    countdown: document.getElementById('countdown-screen')
};

const elements = {
    destinationsList: document.getElementById('destinations-list'),
    addDestinationBtn: document.getElementById('add-destination-btn'),
    addDestinationForm: document.getElementById('add-destination-form'),
    destinationNameInput: document.getElementById('destination-name'),
    destinationAddressInput: document.getElementById('destination-address'),
    addressSuggestions: document.getElementById('address-suggestions'),
    cancelAddBtn: document.getElementById('cancel-add'),
    transportModes: document.querySelectorAll('.transport-mode'),
    startCountdownBtn: document.getElementById('start-countdown-btn'),
    backToHomeBtn: document.getElementById('back-to-home-btn'),
    countdownDestName: document.getElementById('countdown-destination-name'),
    countdownDestAddress: document.getElementById('countdown-destination-address'),
    transportModeDisplay: document.getElementById('transport-mode-display'),
    transportModeText: document.getElementById('transport-mode-text'),
    distanceText: document.getElementById('distance-text'),
    durationText: document.getElementById('duration-text'),
    countdownTimer: document.getElementById('countdown-timer'),
    stopCountdownBtn: document.getElementById('stop-countdown-btn')
};

// App State
const state = {
    destinations: [],
    selectedDestinationId: null,
    selectedTransportMode: null,
    isCountdownActive: false,
    currentLocation: null,
    travelData: null,
    countdownInterval: null,
    addressSearchTimeout: null
};

// Load saved destinations from localStorage
function loadDestinations() {
    const savedDestinations = localStorage.getItem('commuta-destinations');
    if (savedDestinations) {
        state.destinations = JSON.parse(savedDestinations);
        renderDestinationsList();
    }
}

// Save destinations to localStorage
function saveDestinations() {
    localStorage.setItem('commuta-destinations', JSON.stringify(state.destinations));
}

// Render the list of destinations
function renderDestinationsList() {
    elements.destinationsList.innerHTML = '';
    
    if (state.destinations.length === 0) {
        const emptyMessage = document.createElement('p');
        emptyMessage.textContent = 'Keine Ziele gespeichert. Fügen Sie Ihre ersten Ziele hinzu!';
        emptyMessage.style.color = '#6c757d';
        emptyMessage.style.textAlign = 'center';
        emptyMessage.style.padding = '20px 0';
        elements.destinationsList.appendChild(emptyMessage);
        return;
    }
    
    state.destinations.forEach(destination => {
        const li = document.createElement('li');
        li.setAttribute('data-id', destination.id);
        
        li.innerHTML = `
            <div class="destination-info">
                <div class="destination-name">${destination.name}</div>
                <div class="destination-address">${destination.address}</div>
            </div>
            <div class="destination-select">
                <i class="fas fa-chevron-right"></i>
            </div>
        `;
        
        li.addEventListener('click', () => selectDestination(destination));
        
        elements.destinationsList.appendChild(li);
    });
}

// Navigate between screens
function showScreen(screenId) {
    Object.keys(screens).forEach(key => {
        screens[key].classList.remove('active');
    });
    
    screens[screenId].classList.add('active');
}

// Geolocation functions
function getCurrentLocation() {
    return new Promise((resolve, reject) => {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                position => {
                    state.currentLocation = {
                        lat: position.coords.latitude,
                        lng: position.coords.longitude
                    };
                    resolve(state.currentLocation);
                },
                error => {
                    showNotification('Standortzugriff fehlgeschlagen. Bitte aktivieren Sie die Standortfreigabe.', 'error');
                    reject(error);
                }
            );
        } else {
            showNotification('Geolocation wird von Ihrem Browser nicht unterstützt.', 'error');
            reject(new Error('Geolocation not supported'));
        }
    });
}

// Show notification message
function showNotification(message, type = 'info') {
    // Check if notification already exists, if not create one
    let notification = document.querySelector('.notification');
    if (!notification) {
        notification = document.createElement('div');
        notification.className = 'notification';
        document.body.appendChild(notification);
    }
    
    // Set message and type
    notification.textContent = message;
    notification.className = 'notification';
    if (type) notification.classList.add(type);
    
    // Show notification
    notification.style.display = 'block';
    notification.classList.add('fade-in');
    
    // Hide after 3 seconds
    setTimeout(() => {
        notification.classList.remove('fade-in');
        notification.classList.add('fade-out');
        setTimeout(() => {
            notification.style.display = 'none';
        }, 300);
    }, 3000);
}

// Destination selection
function selectDestination(destination) {
    state.selectedDestinationId = destination.id;
    showScreen('destinationPicker');
}

// Transport mode selection
function selectTransportMode(mode) {
    state.selectedTransportMode = mode;
    elements.transportModes.forEach(el => {
        el.classList.remove('selected');
        if (el.getAttribute('data-mode') === mode) {
            el.classList.add('selected');
        }
    });
    
    elements.startCountdownBtn.disabled = false;
}

// Start countdown
async function startCountdown() {
    try {
        await getCurrentLocation();
        
        // Find selected destination
        const destination = state.destinations.find(d => d.id === state.selectedDestinationId);
        if (!destination) throw new Error('Destination not found');
        
        // Prepare countdown screen
        elements.countdownDestName.textContent = destination.name;
        elements.countdownDestAddress.textContent = destination.address;
        
        // Set transport mode icon and text
        const transportIcons = {
            driving: 'fa-car',
            transit: 'fa-bus',
            bicycling: 'fa-bicycle',
            walking: 'fa-walking'
        };
        
        const transportTexts = {
            driving: 'Auto',
            transit: 'ÖPNV',
            bicycling: 'Fahrrad',
            walking: 'Zu Fuß'
        };
        
        const iconElement = elements.transportModeDisplay.querySelector('i');
        iconElement.className = `fas ${transportIcons[state.selectedTransportMode]}`;
        elements.transportModeText.textContent = transportTexts[state.selectedTransportMode];
        
        // Fetch travel data from n8n backend
        state.isCountdownActive = true;
        await fetchTravelData();
        
        // Start the countdown timer
        startCountdownTimer();
        
        // Show countdown screen
        showScreen('countdown');
        
        // Set up periodic refresh (every 60 seconds)
        state.countdownInterval = setInterval(fetchTravelData, 60000);
    } catch (error) {
        console.error('Error starting countdown:', error);
        showNotification('Fehler beim Starten des Countdowns. Bitte versuchen Sie es erneut.', 'error');
    }
}

// Stop countdown
function stopCountdown() {
    state.isCountdownActive = false;
    clearInterval(state.countdownInterval);
    showScreen('home');
}

// Fetch travel data from n8n backend
async function fetchTravelData() {
    try {
        if (!state.currentLocation || !state.selectedDestinationId || !state.selectedTransportMode) {
            throw new Error('Missing required data for travel calculation');
        }
        
        const destination = state.destinations.find(d => d.id === state.selectedDestinationId);
        
        // For MVP, simulate API call
        // In production, this would call the n8n workflow endpoint
        simulateTravelDataFetch(destination);
    } catch (error) {
        console.error('Error fetching travel data:', error);
        showNotification('Fehler beim Abrufen der Reisedaten.', 'error');
    }
}

// Simulate travel data fetch (for MVP)
function simulateTravelDataFetch(destination) {
    // Simulate API delay
    setTimeout(() => {
        // Generate random distance between 1-20 km
        const distanceInMeters = Math.floor(Math.random() * 19000) + 1000;
        
        // Generate travel time based on transport mode
        let durationInSeconds;
        switch (state.selectedTransportMode) {
            case 'driving':
                durationInSeconds = Math.round(distanceInMeters / 10); // ~36 km/h
                break;
            case 'transit':
                durationInSeconds = Math.round(distanceInMeters / 7); // ~25 km/h
                break;
            case 'bicycling':
                durationInSeconds = Math.round(distanceInMeters / 3.5); // ~13 km/h
                break;
            case 'walking':
                durationInSeconds = Math.round(distanceInMeters / 1.4); // ~5 km/h
                break;
            default:
                durationInSeconds = Math.round(distanceInMeters / 10);
        }
        
        // Format distance
        const distanceKm = (distanceInMeters / 1000).toFixed(1);
        const distanceText = `${distanceKm} km`;
        
        // Format duration
        const durationMinutes = Math.floor(durationInSeconds / 60);
        const durationHours = Math.floor(durationMinutes / 60);
        const remainingMinutes = durationMinutes % 60;
        
        let durationText;
        if (durationHours > 0) {
            durationText = `${durationHours} Std. ${remainingMinutes} Min.`;
        } else {
            durationText = `${durationMinutes} Min.`;
        }
        
        // Update travel data state
        state.travelData = {
            distanceInMeters,
            distanceText,
            durationInSeconds,
            durationText,
            departureTime: new Date(Date.now() + durationInSeconds * 1000)
        };
        
        // Update UI
        updateTravelDataUI();
    }, 500);
}

// Update travel data in UI
function updateTravelDataUI() {
    if (!state.travelData) return;
    
    elements.distanceText.textContent = state.travelData.distanceText;
    elements.durationText.textContent = state.travelData.durationText;
    
    // Update countdown timer display
    updateCountdownDisplay();
}

// Start countdown timer
function startCountdownTimer() {
    // Initial update
    updateCountdownDisplay();
    
    // Update every second
    state.countdownInterval = setInterval(updateCountdownDisplay, 1000);
}

// Update countdown display
function updateCountdownDisplay() {
    if (!state.travelData) return;
    
    const now = new Date();
    const departure = state.travelData.departureTime;
    const timeLeft = Math.max(0, Math.floor((departure - now) / 1000));
    
    const minutes = Math.floor(timeLeft / 60);
    const hours = Math.floor(minutes / 60);
    const remainingMinutes = minutes % 60;
    
    // Format as HH:MM
    const formattedHours = String(hours).padStart(2, '0');
    const formattedMinutes = String(remainingMinutes).padStart(2, '0');
    elements.countdownTimer.textContent = `${formattedHours}:${formattedMinutes}`;
    
    // Check for notifications
    if (minutes === 5 && seconds === 0) {
        // 5 minutes warning
        showNotification('Noch 5 Minuten bis zur Abfahrt!', 'warning');
        // Play sound
        playAlertSound('warning');
    } else if (minutes === 0 && timeLeft < 1) {
        // Time's up
        showNotification('Zeit zu gehen! Sie sollten jetzt aufbrechen.', 'error');
        // Play sound
        playAlertSound('alarm');
    }
}

// Play alert sound
function playAlertSound(type) {
    // In a real app, we would implement actual sound playback
    console.log(`Playing ${type} sound`);
}

// Add address search functionality
function setupAddressSearch() {
    elements.destinationAddressInput.addEventListener('input', event => {
        const query = event.target.value.trim();
        
        clearTimeout(state.addressSearchTimeout);
        
        if (query.length < 3) {
            elements.addressSuggestions.style.display = 'none';
            return;
        }
        
        state.addressSearchTimeout = setTimeout(() => {
            // For MVP, simulate address search with dummy data
            simulateAddressSearch(query);
        }, 300);
    });
}

// Simulate address search (for MVP)
function simulateAddressSearch(query) {
    // Sample addresses
    const sampleAddresses = [
        'Hauptstraße 1, 10115 Berlin',
        'Friedrichstraße 50, 10117 Berlin',
        'Kurfürstendamm 101, 10711 Berlin',
        'Alexanderplatz, 10178 Berlin',
        'Potsdamer Platz, 10785 Berlin'
    ];
    
    // Filter addresses that contain the query (case insensitive)
    const filtered = sampleAddresses.filter(address => 
        address.toLowerCase().includes(query.toLowerCase())
    );
    
    // Display results
    if (filtered.length > 0) {
        elements.addressSuggestions.innerHTML = '';
        filtered.forEach(address => {
            const div = document.createElement('div');
            div.textContent = address;
            div.addEventListener('click', () => {
                elements.destinationAddressInput.value = address;
                elements.addressSuggestions.style.display = 'none';
            });
            elements.addressSuggestions.appendChild(div);
        });
        elements.addressSuggestions.style.display = 'block';
    } else {
        elements.addressSuggestions.style.display = 'none';
    }
}

// Initialize the app
function initApp() {
    // Load saved destinations
    loadDestinations();
    
    // Request location permission early
    getCurrentLocation().catch(() => {
        // Handle initial location error silently
    });
    
    // Setup address search
    setupAddressSearch();
    
    // Event Listeners
    elements.addDestinationBtn.addEventListener('click', () => {
        showScreen('addDestination');
    });
    
    elements.cancelAddBtn.addEventListener('click', () => {
        showScreen('home');
    });
    
    elements.addDestinationForm.addEventListener('submit', event => {
        event.preventDefault();
        
        const name = elements.destinationNameInput.value.trim();
        const address = elements.destinationAddressInput.value.trim();
        
        if (!name || !address) {
            showNotification('Bitte füllen Sie alle Felder aus.', 'error');
            return;
        }
        
        // Add new destination
        const newDestination = {
            id: Date.now().toString(),
            name,
            address,
            // For MVP, we'll use dummy coordinates
            latitude: 52.520008 + (Math.random() * 0.1 - 0.05),
            longitude: 13.404954 + (Math.random() * 0.1 - 0.05)
        };
        
        state.destinations.push(newDestination);
        saveDestinations();
        
        // Reset form
        elements.destinationNameInput.value = '';
        elements.destinationAddressInput.value = '';
        
        // Return to home screen
        showScreen('home');
        renderDestinationsList();
        
        showNotification('Ziel erfolgreich hinzugefügt!');
    });
    
    elements.transportModes.forEach(el => {
        el.addEventListener('click', () => {
            selectTransportMode(el.getAttribute('data-mode'));
        });
    });
    
    elements.startCountdownBtn.addEventListener('click', startCountdown);
    
    elements.backToHomeBtn.addEventListener('click', () => {
        showScreen('home');
    });
    
    elements.stopCountdownBtn.addEventListener('click', stopCountdown);
    
    // Close address suggestions when clicking outside
    document.addEventListener('click', event => {
        if (!elements.addressSuggestions.contains(event.target) && 
            event.target !== elements.destinationAddressInput) {
            elements.addressSuggestions.style.display = 'none';
        }
    });
}

// Start the app when DOM is ready
document.addEventListener('DOMContentLoaded', initApp);
