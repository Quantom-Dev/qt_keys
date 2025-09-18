import { menuStyles } from './quantom-menu.js';

const app = Vue.createApp({
    data() {
        return {
            playerJob: '',
            playerId: 0,
            menuVisible: false,
            activeMenu: 'main',
            nearbyPlayers: [],
            vehicles: [],
            selectedVehicle: null,
            playerKeys: [],
            selectedKey: null,
            manualKeyForm: {
                plate: '',
                model: ''
            },
            dealerConfig: {
                defaultMenu: 'main',
                showControls: true,
                showHint: false,
                menus: {
                    main: {
                        title: "Gestion des Clés",
                        subtitle: "Concessionnaire",
                        items: [
                            { label: "Véhicules à proximité", icon: "fas fa-car", submenu: "nearby_vehicles" },
                            { label: "Créer une clé manuelle", icon: "fas fa-key", submenu: "create_key" },
                            { label: "Mes clés", icon: "fas fa-key", submenu: "my_keys" },
                            { label: "Fermer", icon: "fas fa-times-circle", action: "close" }
                        ]
                    },
                    nearby_vehicles: {
                        title: "Véhicules à proximité",
                        items: [
                            { label: "Retour", icon: "fas fa-arrow-left", submenu: "main" }
                        ]
                    },
                    create_key: {
                        title: "Créer une clé",
                        items: [
                            { label: "Entrer la plaque", icon: "fas fa-keyboard", action: "enter_plate" },
                            { label: "Entrer le modèle", icon: "fas fa-car", action: "enter_model" },
                            { label: "Créer la clé", icon: "fas fa-plus-circle", action: "create_manual_key" },
                            { label: "Retour", icon: "fas fa-arrow-left", submenu: "main" }
                        ]
                    },
                    my_keys: {
                        title: "Mes clés",
                        items: [
                            { label: "Retour", icon: "fas fa-arrow-left", submenu: "main" }
                        ]
                    },
                    vehicle_options: {
                        title: "Options du véhicule",
                        items: [
                            { label: "Créer une clé pour moi", icon: "fas fa-key", action: "create_key_self" },
                            { label: "Créer une clé pour un joueur", icon: "fas fa-user", submenu: "select_player" },
                            { label: "Retour", icon: "fas fa-arrow-left", submenu: "nearby_vehicles" }
                        ]
                    },
                    select_player: {
                        title: "Sélectionner un joueur",
                        items: [
                            { label: "Retour", icon: "fas fa-arrow-left", submenu: "vehicle_options" }
                        ]
                    },
                    key_options: {
                        title: "Options de la clé",
                        items: [
                            { label: "Donner à un joueur", icon: "fas fa-user", submenu: "select_player_give" },
                            { label: "Retour", icon: "fas fa-arrow-left", submenu: "my_keys" }
                        ]
                    },
                    select_player_give: {
                        title: "Donner la clé à",
                        items: [
                            { label: "Retour", icon: "fas fa-arrow-left", submenu: "key_options" }
                        ]
                    }
                },
                actions: {
                    enter_plate: function() {
                        app.promptPlate();
                    },
                    enter_model: function() {
                        app.promptModel();
                    },
                    create_manual_key: function() {
                        app.createManualKey();
                    },
                    create_key_self: function() {
                        if (app.selectedVehicle) {
                            app.createKey(app.playerId, app.selectedVehicle.plate, app.selectedVehicle.model);
                        }
                    }
                }
            },
            dealerTheme: {
                background: 'rgba(10, 10, 30, 0.8)',
                headerBackground: 'rgba(20, 20, 40, 0.9)',
                accent: '#3974c8',
                width: '400px'
            },
            notification: {
                show: false,
                message: '',
                type: 'success',
                icon: 'fas fa-check-circle'
            }
        };
    },
    mounted() {
        const style = document.createElement('style');
        style.innerHTML = menuStyles;
        document.head.appendChild(style);
        window.addEventListener('message', this.handleMessage);
    },
    beforeUnmount() {
        window.removeEventListener('message', this.handleMessage);
    },
    methods: {
        handleMessage(event) {
            const data = event.data;
            
            if (data.type === 'openCardealerMenu') {
                this.playerJob = data.job || '';
                this.playerId = data.playerId || 0;
                this.vehicles = data.vehicles || [];
                this.nearbyPlayers = data.players || [];
                this.playerKeys = data.keys || [];
                this.openMenu();
            } 
            else if (data.type === 'updateNearbyData') {
                this.vehicles = data.vehicles || this.vehicles;
                this.nearbyPlayers = data.players || this.nearbyPlayers;
                this.playerKeys = data.keys || this.playerKeys;
            }
        },
        openMenu(startMenu = null) {
            this.menuVisible = true;
            this.activeMenu = startMenu || this.dealerConfig.defaultMenu;
        },
        closeMenu() {
            this.menuVisible = false;
            fetch(`https://${GetParentResourceName()}/closeMenu`, {
                method: 'POST'
            }).catch(e => {});
        },
        navigateTo(menuName) {
            if (this.dealerConfig.menus[menuName]) {
                this.activeMenu = menuName;
            }
        },
        promptPlate() {
            const plateInput = prompt("Entrez la plaque du véhicule:", this.manualKeyForm.plate);
            if (plateInput !== null) {
                this.manualKeyForm.plate = plateInput.toUpperCase();
                this.showNotification("Plaque enregistrée: " + this.manualKeyForm.plate, "success");
            }
        },
        promptModel() {
            const modelInput = prompt("Entrez le modèle du véhicule:", this.manualKeyForm.model);
            if (modelInput !== null) {
                this.manualKeyForm.model = modelInput;
                this.showNotification("Modèle enregistré: " + this.manualKeyForm.model, "success");
            }
        },
        createManualKey() {
            if (!this.manualKeyForm.plate) {
                this.showNotification("Veuillez entrer une plaque", "error");
                return;
            }
            const model = this.manualKeyForm.model || "Véhicule";
            this.createKey(this.playerId, this.manualKeyForm.plate, model);
            this.manualKeyForm.plate = '';
            this.manualKeyForm.model = '';
            this.navigateTo('main');
        },
        createKey(targetId, plate, model) {
            fetch(`https://${GetParentResourceName()}/createKey`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({targetId, plate, model})
            }).catch(e => {});
        },
        giveKey(targetId, plate, model) {
            fetch(`https://${GetParentResourceName()}/giveKey`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({targetId, plate, model})
            }).catch(e => {});
        },
        showNotification(message, type = 'success') {
            let icon = 'fas fa-check-circle';
            if (type === 'error') icon = 'fas fa-exclamation-circle';
            if (type === 'warning') icon = 'fas fa-exclamation-triangle';
            
            this.notification = {
                show: true,
                message,
                type,
                icon
            };
            
            setTimeout(() => {
                this.notification.show = false;
            }, 3000);
        }
    }
});

app.component('QuantomMenu', {
    props: {
        config: Object,
        theme: Object,
        activationKey: String,
        type: {type: String, default: 'list'},
        customToggle: {type: Boolean, default: false}
    },
    template: `
        <div v-if="$parent.menuVisible" class="quantom-menu-container" :style="menuStyle">
            <div class="quantom-menu" :class="['type-' + type]">
                <div class="menu-header">
                    <div class="title">{{ currentMenu.title }}</div>
                    <div v-if="currentMenu.subtitle" class="subtitle">{{ currentMenu.subtitle }}</div>
                </div>
                <div class="menu-items">
                    <div v-for="(item, index) in currentMenu.items" :key="index"
                        class="menu-item" :class="{'active': index === $parent.activeIndex, 'disabled': item.disabled}"
                        @click="!item.disabled && selectItem(item)">
                        <div v-if="item.icon" class="item-icon"><i :class="item.icon"></i></div>
                        <div class="item-label">{{ item.label }}</div>
                        <div v-if="item.rightLabel" class="item-right-label">{{ item.rightLabel }}</div>
                        <div v-if="item.submenu" class="item-arrow"><i class="fas fa-chevron-right"></i></div>
                    </div>
                </div>
                <div class="menu-footer" v-if="config.showControls !== false">
                    <div class="navigation-hint">
                        <i class="fas fa-arrow-up"></i> <i class="fas fa-arrow-down"></i> Naviguer
                        <span class="divider">|</span>
                        <i class="fas fa-arrow-right"></i> Sélectionner
                        <span class="divider">|</span>
                        <i class="fas fa-arrow-left"></i> Retour
                        <span class="divider">|</span>
                        <span class="esc-key">ESC</span> Fermer
                    </div>
                </div>
            </div>
            <div class="menu-notification" :class="[$parent.notification.show ? 'show' : 'hidden', $parent.notification.type]">
                <i :class="$parent.notification.icon"></i>
                {{ $parent.notification.message }}
            </div>
        </div>
    `,
    computed: {
        currentMenu() {
            const menu = this.config.menus[this.$parent.activeMenu] || { items: [] };
            
            if (this.$parent.activeMenu === 'nearby_vehicles') {
                menu.items = this.$parent.vehicles.map((vehicle, index) => ({
                    label: `${vehicle.model} - ${vehicle.plate}`,
                    icon: "fas fa-car",
                    action: "select_vehicle",
                    data: { index }
                }));
                menu.items.push({ label: "Retour", icon: "fas fa-arrow-left", submenu: "main" });
            } 
            else if (this.$parent.activeMenu === 'my_keys') {
                menu.items = this.$parent.playerKeys.map((key, index) => ({
                    label: `${key.model} - ${key.plate}`,
                    icon: "fas fa-key",
                    action: "select_key",
                    data: { index }
                }));
                menu.items.push({ label: "Retour", icon: "fas fa-arrow-left", submenu: "main" });
            }
            else if (this.$parent.activeMenu === 'select_player' || this.$parent.activeMenu === 'select_player_give') {
                menu.items = this.$parent.nearbyPlayers.map((player, index) => ({
                    label: `${player.name} (${player.id})`,
                    icon: "fas fa-user",
                    action: this.$parent.activeMenu === 'select_player' ? "create_key_for_player" : "give_key_to_player",
                    data: { playerId: player.id }
                }));
                
                menu.items.push({ 
                    label: "Retour", 
                    icon: "fas fa-arrow-left", 
                    submenu: this.$parent.activeMenu === 'select_player' ? "vehicle_options" : "key_options" 
                });
            }
            
            return menu;
        },
        menuStyle() {
            return {
                '--menu-bg': this.theme.background || 'rgba(0, 0, 0, 0.6)',
                '--menu-header-bg': this.theme.headerBackground || 'rgba(0, 0, 0, 0.4)',
                '--menu-item-hover': this.theme.itemHover || 'rgba(159, 157, 160, 0.2)',
                '--menu-item-active': this.theme.itemActive || 'rgba(159, 157, 160, 0.4)',
                '--menu-accent': this.theme.accent || 'rgb(159, 157, 160)',
                '--menu-text': this.theme.textColor || 'white',
                '--menu-width': this.theme.width || '400px',
            };
        }
    },
    methods: {
        selectItem(item) {
            if (item.submenu) {
                this.$parent.navigateTo(item.submenu);
            } else if (item.action) {
                this.handleAction(item.action, item.data || {});
            }
        },
        handleAction(action, data = {}) {
            if (action === 'close') {
                this.$parent.closeMenu();
            } 
            else if (action === 'select_vehicle') {
                this.$parent.selectedVehicle = this.$parent.vehicles[data.index];
                this.$parent.navigateTo('vehicle_options');
            } 
            else if (action === 'select_key') {
                this.$parent.selectedKey = this.$parent.playerKeys[data.index];
                this.$parent.navigateTo('key_options');
            } 
            else if (action === 'create_key_for_player') {
                this.$parent.createKey(data.playerId, this.$parent.selectedVehicle.plate, this.$parent.selectedVehicle.model);
                this.$parent.showNotification(`Clé créée pour le joueur #${data.playerId}`, 'success');
                this.$parent.navigateTo('main');
            } 
            else if (action === 'give_key_to_player') {
                this.$parent.giveKey(data.playerId, this.$parent.selectedKey.plate, this.$parent.selectedKey.model);
                this.$parent.showNotification(`Clé donnée au joueur #${data.playerId}`, 'success');
                this.$parent.navigateTo('main');
            }
            else if (this.config.actions && typeof this.config.actions[action] === 'function') {
                this.config.actions[action](data);
            }
            
            if (data.notification) {
                this.$parent.showNotification(
                    data.notification.message, 
                    data.notification.type || 'success'
                );
            }
        }
    },
    mounted() {
        window.addEventListener('keydown', (e) => {
            if (!this.$parent.menuVisible) {
                return;
            }
            
            switch (e.key) {
                case 'Escape':
                    this.$parent.closeMenu();
                    break;
                case 'ArrowUp':
                    this.$parent.activeIndex = this.$parent.activeIndex > 0 
                        ? this.$parent.activeIndex - 1 
                        : this.currentMenu.items.length - 1;
                    break;
                case 'ArrowDown':
                    this.$parent.activeIndex = this.$parent.activeIndex < this.currentMenu.items.length - 1 
                        ? this.$parent.activeIndex + 1 
                        : 0;
                    break;
                case 'ArrowRight':
                case 'Enter':
                    const item = this.currentMenu.items[this.$parent.activeIndex];
                    this.selectItem(item);
                    break;
                case 'ArrowLeft':
                case 'Backspace':
                    const parentMenu = Object.entries(this.config.menus).find(([key, menu]) => 
                        menu.items && menu.items.some(item => item.submenu === this.$parent.activeMenu)
                    );
                    
                    if (parentMenu) {
                        this.$parent.navigateTo(parentMenu[0]);
                    } else {
                        this.$parent.navigateTo('main');
                    }
                    break;
            }
        });
    }
});

const mountedApp = app.mount('#cardealer-keys-app');