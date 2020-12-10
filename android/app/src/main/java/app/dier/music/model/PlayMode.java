package app.dier.music.model;

public enum PlayMode {

    repeat("repeat"),
    repeatOne("repeatOne"),
    random("random");

    private final String name;

    PlayMode(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }
}
