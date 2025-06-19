class Config(object):
    LOGGER = True

    # Get this value from my.telegram.org/apps
    API_ID = 29379658
    API_HASH = "1af3078d6540f9812b1bf489cb27aa99"

    CASH_API_KEY = "VGL2K9U4QQNYBI5E"  # Get this value for currency converter from https://www.alphavantage.co/support/#api-key

    DATABASE_URL = "mongodb+srv://yann:xdisable@bot.kst9dnw.mongodb.net/?retryWrites=true&w=majority&appName=Bot"  # A sql database url from elephantsql.com

    EVENT_LOGS = (-1002859531695)  # Event logs channel to note down important bot level events

    MONGO_DB_URI = "mongodb+srv://yann:xdisable@bot.kst9dnw.mongodb.net/?retryWrites=true&w=majority&appName=Bot"  # Get ths value from cloud.mongodb.com

    # Telegraph link of the image which will be shown at start command.
    START_IMG = "https://te.legra.ph/file/40eb1ed850cdea274693e.jpg"

    SUPPORT_CHAT = "vyngov"  # Your Telegram support group chat username where your users will go and bother you

    TOKEN = "6919096854:AAENE5jhcSWbTdWFo7eyS1wx9i_IYB70cSs"  # Get bot token from @BotFather on Telegram

    TIME_API_KEY = "9QPR7QJ53JSN"  # Get this value from https://timezonedb.com/api

    OWNER_ID = 7883337426  # User id of your telegram account (Must be integer)

    # Optional fields
    BL_CHATS = []  # List of groups that you want blacklisted.
    DRAGONS = [7883337426]  # User id of sudo users
    DEV_USERS = [7883337426]  # User id of dev users
    DEMONS = []  # User id of support users
    TIGERS = []  # User id of tiger users
    WOLVES = []  # User id of whitelist users

    ALLOW_CHATS = True
    ALLOW_EXCL = True
    DEL_CMDS = True
    INFOPIC = True
    LOAD = []
    NO_LOAD = []
    STRICT_GBAN = True
    TEMP_DOWNLOAD_DIRECTORY = "./"
    WORKERS = 8


class Production(Config):
    LOGGER = True


class Development(Config):
    LOGGER = True
