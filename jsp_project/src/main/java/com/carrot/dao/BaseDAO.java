package com.carrot.dao;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public abstract class BaseDAO {
    private static final String DATA_SOURCE_NAME = "jdbc/oracle";

    protected Connection getConnection() throws SQLException {
        try {
            Context initContext = new InitialContext();
            Context envContext = (Context) initContext.lookup("java:/comp/env");
            DataSource dataSource = (DataSource) envContext.lookup(DATA_SOURCE_NAME);
            return dataSource.getConnection();
        } catch (NamingException e) {
            throw new SQLException("JNDI DataSource not found: " + DATA_SOURCE_NAME, e);
        }
    }

    protected void close(ResultSet rs, Statement stmt, Connection conn) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException ignored) {
            }
        }

        close(stmt, conn);
    }

    protected void close(Statement stmt, Connection conn) {
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException ignored) {
            }
        }

        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException ignored) {
            }
        }
    }
}
