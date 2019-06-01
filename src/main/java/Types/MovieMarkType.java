package Types;

import java.sql.Date;

public class MovieMarkType {
    private Integer movie_id;
    private String login;
    private Integer mark;
    private String heart;
    private Date seen;

    public MovieMarkType(Integer movie_id, String login, Integer mark, String heart, Date seen) {
        this.movie_id = movie_id;
        this.login = login;
        this.mark = mark;
        this.heart = heart;
        this.seen = seen;
    }

    public Integer getMovie_id() {
        return movie_id;
    }

    public void setMovie_id(Integer movie_id) {
        this.movie_id = movie_id;
    }

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    public Integer getMark() {
        return mark;
    }

    public void setMark(Integer mark) {
        this.mark = mark;
    }

    public String getHeart() {
        return heart;
    }

    public void setHeart(String heart) {
        this.heart = heart;
    }

    public Date getSeen() {
        return seen;
    }

    public void setSeen(Date seen) {
        this.seen = seen;
    }
}
