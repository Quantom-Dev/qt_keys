const menuStyles = `
@import url('https://fonts.googleapis.com/css?family=Poppins:200,400,500,600,700');

.quantom-menu-container {
    display: flex;
    align-items: center;
    justify-content: center;
    position: absolute;
    top: 0;
    left: 0;
    height: 100vh;
    width: 100vw;
    background: rgba(0, 0, 0, 0.3);
    z-index: 1000;
    font-family: 'Poppins', sans-serif;
}

.quantom-menu {
    width: var(--menu-width, 400px);
    background: var(--menu-bg, rgba(0, 0, 0, 0.6));
    border-radius: 5px;
    overflow: hidden;
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
    color: var(--menu-text, white);
}

.menu-header {
    background: var(--menu-header-bg, rgba(0, 0, 0, 0.4));
    padding: 15px 20px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.title {
    font-size: 18px;
    font-weight: 600;
}

.subtitle {
    font-size: 14px;
    opacity: 0.8;
    margin-top: 5px;
}

.menu-items {
    max-height: 450px;
    overflow-y: auto;
}

.menu-item {
    display: flex;
    align-items: center;
    padding: 12px 20px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    cursor: pointer;
    transition: background 0.2s;
}

.menu-item:hover {
    background: var(--menu-item-hover, rgba(159, 157, 160, 0.2));
}

.menu-item.active {
    background: var(--menu-item-active, rgba(159, 157, 160, 0.4));
    border-left: 3px solid var(--menu-accent, rgb(159, 157, 160));
}

.menu-item.disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

.item-icon {
    width: 30px;
    text-align: center;
    margin-right: 15px;
}

.item-label {
    flex-grow: 1;
}

.item-right-label {
    margin-left: 10px;
    opacity: 0.8;
}

.item-arrow {
    font-size: 12px;
    opacity: 0.7;
}

.menu-footer {
    background: var(--menu-header-bg, rgba(0, 0, 0, 0.4));
    padding: 10px 20px;
    font-size: 12px;
    color: rgba(255, 255, 255, 0.7);
}

.navigation-hint {
    display: flex;
    align-items: center;
    justify-content: center;
}

.divider {
    margin: 0 10px;
}

.esc-key {
    background: rgba(159, 157, 160, 0.3);
    padding: 2px 5px;
    border-radius: 3px;
}

.menu-hint {
    position: absolute;
    bottom: 5vh;
    left: 50%;
    transform: translateX(-50%);
    color: white;
    background: rgba(0, 0, 0, 0.6);
    padding: 10px 20px;
    border-radius: 5px;
    font-size: 16px;
    z-index: 900;
}

.key {
    background: rgba(159, 157, 160, 0.6);
    padding: 2px 8px;
    border-radius: 3px;
    margin: 0 3px;
}

.menu-notification {
    position: fixed;
    top: 30px;
    right: 30px;
    padding: 15px 20px;
    border-radius: 5px;
    color: white;
    font-size: 14px;
    display: flex;
    align-items: center;
    gap: 10px;
    z-index: 1100;
    opacity: 0;
    transition: opacity 0.3s;
}

.menu-notification.success {
    background-color: #2bad6e;
}

.menu-notification.error {
    background-color: #c33131;
}

.menu-notification.warning {
    background-color: #c96e06;
}

.menu-notification.show {
    opacity: 1;
}

.menu-notification.hidden {
    opacity: 0;
}

.menu-items::-webkit-scrollbar {
    width: 5px;
}

.menu-items::-webkit-scrollbar-track {
    background: rgba(0, 0, 0, 0.4);
}

.menu-items::-webkit-scrollbar-thumb {
    background: var(--menu-accent, rgb(159, 157, 160));
    border-radius: 3px;
}

.quantom-menu.type-grid .menu-items {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    grid-gap: 10px;
    padding: 15px;
}

.quantom-menu.type-grid .menu-item {
    flex-direction: column;
    height: 100px;
    text-align: center;
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 5px;
}

.quantom-menu.type-grid .item-icon {
    width: auto;
    margin: 0 0 10px 0;
    font-size: 24px;
}

.quantom-menu.type-shop .menu-items {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    grid-gap: 15px;
    padding: 20px;
}

.quantom-menu.type-shop .menu-item {
    flex-direction: column;
    height: 150px;
    border-radius: 8px;
    padding: 15px;
    position: relative;
    overflow: hidden;
}

.quantom-menu.type-shop .item-label {
    margin-top: auto;
    font-weight: 500;
}

.quantom-menu.type-shop .item-right-label {
    position: absolute;
    top: 10px;
    right: 10px;
    background: rgba(0, 0, 0, 0.5);
    padding: 5px 8px;
    border-radius: 3px;
    font-size: 12px;
}
`;

const QuantomMenu = {
    props: {
        config: Object,
        theme: Object,
        activationKey: String,
        type: {
            type: String,
            default: 'list'
        },
        customToggle: {
            type: Boolean,
            default: false
        }
    },
    data() {
        return {
            visible: false,
            activeMenu: '',
            activeIndex: 0,
            history: [],
            notification: {
                show: false,
                message: '',
                type: 'success',
                icon: 'fas fa-check-circle'
            }
        };
    },
    computed: {
        currentMenu() {
            return this.config.menus[this.activeMenu] || { items: [] };
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
        openMenu(startMenu = null) {
            this.visible = true;
            this.activeMenu = startMenu || this.config.defaultMenu || Object.keys(this.config.menus)[0];
            this.activeIndex = 0;
            this.history = [];
        },
        
        closeMenu() {
            this.visible = false;
            this.$emit('close');
        },
        
        navigateTo(menuName) {
            if (this.config.menus[menuName]) {
                this.history.push(this.activeMenu);
                this.activeMenu = menuName;
                this.activeIndex = 0;
            }
        },
        
        goBack() {
            if (this.history.length > 0) {
                this.activeMenu = this.history.pop();
                this.activeIndex = 0;
            } else {
                this.closeMenu();
            }
        },
        
        handleAction(action, data = {}) {
            this.$emit('action', action, data);
            
            if (action === 'close') {
                this.closeMenu();
            } else if (this.config.actions && typeof this.config.actions[action] === 'function') {
                this.config.actions[action](data);
            }
            
            if (data.notification) {
                this.showNotification(
                    data.notification.message, 
                    data.notification.type || 'success'
                );
            }
        },
        
        selectItem(item) {
            if (item.submenu) {
                this.navigateTo(item.submenu);
            } else if (item.action) {
                this.handleAction(item.action, item.data || {});
            }
        },
        
        handleKeyDown(e) {
            if (!this.visible) {
                if (!this.customToggle && e.key.toLowerCase() === this.activationKey.toLowerCase()) {
                    this.openMenu();
                }
                return;
            }
            
            switch (e.key) {
                case 'Escape':
                    this.closeMenu();
                    break;
                case 'ArrowUp':
                    this.activeIndex = this.activeIndex > 0 
                        ? this.activeIndex - 1 
                        : this.currentMenu.items.length - 1;
                    break;
                case 'ArrowDown':
                    this.activeIndex = this.activeIndex < this.currentMenu.items.length - 1 
                        ? this.activeIndex + 1 
                        : 0;
                    break;
                case 'ArrowRight':
                case 'Enter':
                    const item = this.currentMenu.items[this.activeIndex];
                    this.selectItem(item);
                    break;
                case 'ArrowLeft':
                case 'Backspace':
                    this.goBack();
                    break;
            }
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
    },
    mounted() {
        if (!this.customToggle) {
            window.addEventListener('keydown', this.handleKeyDown);
        }
    },
    beforeUnmount() {
        if (!this.customToggle) {
            window.removeEventListener('keydown', this.handleKeyDown);
        }
    },
    template: `
        <div v-if="visible" class="quantom-menu-container" :style="menuStyle">
            <div class="quantom-menu" :class="['type-' + type]">
                <div class="menu-header">
                    <div class="title">{{ currentMenu.title }}</div>
                    <div v-if="currentMenu.subtitle" class="subtitle">{{ currentMenu.subtitle }}</div>
                </div>
                
                <div class="menu-items">
                    <div 
                        v-for="(item, index) in currentMenu.items" 
                        :key="index"
                        class="menu-item"
                        :class="{ 
                            'active': index === activeIndex,
                            'disabled': item.disabled
                        }"
                        @click="!item.disabled && selectItem(item)"
                    >
                        <div v-if="item.icon" class="item-icon">
                            <i :class="item.icon"></i>
                        </div>
                        <div class="item-label">{{ item.label }}</div>
                        <div v-if="item.rightLabel" class="item-right-label">{{ item.rightLabel }}</div>
                        <div v-if="item.submenu" class="item-arrow">
                            <i class="fas fa-chevron-right"></i>
                        </div>
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
            
            <div 
                class="menu-notification" 
                :class="[
                    notification.show ? 'show' : 'hidden',
                    notification.type
                ]"
            >
                <i :class="notification.icon"></i>
                {{ notification.message }}
            </div>
        </div>
        
        <div v-else-if="config.showHint !== false" class="menu-hint">
            Appuyez sur <span class="key">{{ activationKey }}</span> pour ouvrir le menu
        </div>
    `
};

const defaultOptions = {
    theme: {
        background: 'rgba(0, 0, 0, 0.6)',
        headerBackground: 'rgba(0, 0, 0, 0.4)',
        itemHover: 'rgba(159, 157, 160, 0.2)',
        itemActive: 'rgba(159, 157, 160, 0.4)',
        accent: 'rgb(159, 157, 160)',
        textColor: 'white',
        width: '400px'
    },
    controls: {
        up: 'ArrowUp',
        down: 'ArrowDown',
        select: 'Enter',
        back: 'Backspace',
        close: 'Escape'
    }
};

export default {
    install(app, options = {}) {
        app.component('QuantomMenu', QuantomMenu);
        app.config.globalProperties.$menuOptions = {
            ...defaultOptions,
            ...options
        };
    }
};

export { menuStyles };