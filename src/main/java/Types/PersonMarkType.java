package Types;

public class PersonMarkType {
    private Integer person_id;
    private String login;
    private Integer mark;
    private String heart;

    public PersonMarkType(Integer person_id, String login, Integer mark, String heart) {
        this.person_id = person_id;
        this.login = login;
        this.mark = mark;
        this.heart = heart;
    }

    public Integer getPerson_id() {
        return person_id;
    }

    public String getLogin() {
        return login;
    }

    public Integer getMark() {
        return mark;
    }

    public String getHeart() {
        return heart;
    }

    public void setHeart(String heart) {
        this.heart = heart;
    }
}
